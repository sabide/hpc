#include "mpi.h"
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#ifdef USE_MKL
#include <mkl.h>
#endif

int tag=1000;

/* Allocate matrix and init to zero */
void matrix_allocate(double **mat, int linenbr, int colnbr) {
  int iter;
  (*mat) = (double *) malloc(linenbr*colnbr*sizeof(double));
  for (iter=0; iter<linenbr*colnbr; iter++) {
    (*mat)[iter] = 0.; }
}

/* Init matrix with random number */
void random_number(double *mat,int n) {
  int iterl,iterc;
  for(iterl=0; iterl<n; iterl++)
    for(iterc=0;iterc<n; iterc++)
      mat[iterl*n+iterc] =  rand() / (RAND_MAX + 1.);
}

/* Matrix product C = A*B */
void matmul(double *A, double *B, double *C,int nl, int nc, int nk) {
#ifdef USE_MKL
  double alpha,beta;
  alpha = 1.0;
  beta = 0.0;
  mkl_set_num_threads(1);
  cblas_dgemm(CblasRowMajor, CblasNoTrans, CblasNoTrans,
              nl, nc, nk, alpha, A, nk, B, nc, beta, C, nc);
#else
  int iterl,iterc,iterk;
  double sum;
  for(iterl=0;iterl<nl;iterl++) {
    for(iterc=0;iterc<nc;iterc++) {
      sum = 0;
      for(iterk=0;iterk<nk;iterk++) {
        sum += A[iterl*nk+iterk]*B[iterk*nc+iterc]; }
      C[iterl*nc+iterc] = sum;
    }
  }
#endif
}

int main(int argc, char *argv[]) {
  int rank,Nprocs,N,NL=0;
  double *A,*B,*C,*CC;
  double *AL,*BL,*CL,*TEMP;
  MPI_Datatype type_temp,type_slice;
  int double_size;
  MPI_Aint lbound,displacement;
  int iter;
  MPI_Status status;
  int previous_rank,following_rank;

  /* Init MPI */
  MPI_Init(&argc, &argv);
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &Nprocs);

  if (rank == 0) {
    FILE * fichier = fopen("matrix_products.data","r");
    if (fscanf(fichier, "%d", &N) != 1)
      N = 512;
    fclose(fichier);
  }

  /* Process 0 broadcast N */
  MPI_Bcast(&N,1,MPI_INT,0,MPI_COMM_WORLD);

  /* N need to be divisible by Nprocs */
  if ( (N % Nprocs) == 0)
    NL = N/Nprocs;
  else {
    fprintf(stderr, "N is not divisible by Nprocs\n");
    /* We stop the program */
    MPI_Abort(MPI_COMM_WORLD,1);
  }

  /* Process 0 init matrices A and B */
  if (rank ==0) {
    /* Dynamic allocation of matrices A, B & C */
    matrix_allocate(&A,N,N);matrix_allocate(&B,N,N);
    matrix_allocate(&C,N,N);matrix_allocate(&CC,N,N);

    /* Init A & B */
    random_number(A,N);
    random_number(B,N);

    /* Sequential computation of A*B */
    matmul(A,B,CC,N,N,N);
  }

  /* Dynamoc allocation of local matrices */
  matrix_allocate(&AL,NL,N);matrix_allocate(&BL,N,NL);
  matrix_allocate(&CL,N,NL);matrix_allocate(&TEMP,NL,N);

  /* Build datatype for 1 chunck of N lignes & NL colonnes */
  MPI_Type_vector(N,NL,N,MPI_DOUBLE,&type_temp);
  MPI_Type_size(MPI_DOUBLE,&double_size);
  lbound = 0;
  displacement = double_size*NL;
  MPI_Type_create_resized(type_temp,lbound,displacement,
                          &type_slice);
  MPI_Type_commit(&type_slice);

  /* Processus 0 distribute in AL the horizontal slices of A */
  MPI_Scatter(A, N*NL, MPI_DOUBLE, AL, N*NL, MPI_DOUBLE,
              0, MPI_COMM_WORLD);

  /* Processus 0 distribute in BL the vertical slices of B */
  MPI_Scatter(B,1,type_slice,BL,N*NL,MPI_DOUBLE,
              0,MPI_COMM_WORLD);

  /* Computation of the diagonal blocks */
  matmul(AL,BL,&(CL[rank*NL*NL]),NL,NL,N);

  /* Computation for none diagonal blocks */

  /* First algorithm
  for (iter=0; iter<Nprocs; iter++) {
    if (rank != iter) {
      // Each process sned his AL slice to process iter
      // and receives in TEMP the AL slice of process iter
      MPI_Sendrecv(AL,NL*N,MPI_DOUBLE,iter,tag,
                   TEMP,NL*N,MPI_DOUBLE,iter,tag,
                   MPI_COMM_WORLD,&status);
      // Each process calculates his blocks above or below the diagonal block
      matmul(TEMP,BL,&(CL[iter*NL*NL]),NL,NL,N);
    }
  }*/
  /* Second algorithm */
  previous_rank = (Nprocs+rank-1)%Nprocs;
  following_rank = (rank+1)%Nprocs;
  for (iter=1; iter<Nprocs; iter++) {
    // Each process sned his AL slice to his previous process
    // and receives the AL slice from the next process ( the values of AL changed)
    MPI_Sendrecv_replace(AL,NL*N,MPI_DOUBLE,previous_rank,tag,
                         following_rank,tag,MPI_COMM_WORLD,&status);
    // Each process calculates his block above or below the diagonal block
    matmul(AL,BL,&(CL[( (rank+iter)%Nprocs )*NL*NL]),NL,NL,N);
  }

  /* The process 0 gather all CL slices from each processes to form the C matrix */
  MPI_Gather(CL,NL*N,MPI_DOUBLE,C,1,type_slice,0,MPI_COMM_WORLD);

  /* Deallocate locals arrays */
  free(AL); free(BL); free(CL); free(TEMP);
  /* Verification of the results */
  if (rank == 0) {
    double Emax=0;
    for(iter=0; iter<N*N; iter++) {
      if (Emax < fabs(C[iter]-CC[iter])) {
        Emax = fabs(C[iter]-CC[iter]); }}
    free(A); free(B); free(C); free(CC);
    if (Emax < 1e-10)
      printf("Super !\nMatrix product A*B in parallel\n"
             "equal the sequential one\n");
    else
      printf("False result !\nMatrix product A*B in parallel\n"
             "different from the sequential one\n");
  }

  /* Finalize MPI */
  MPI_Type_free(&type_temp);
  MPI_Type_free(&type_slice);
  MPI_Finalize();
  return 0;
}
