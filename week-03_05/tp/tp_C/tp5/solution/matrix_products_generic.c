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
  int rank,Nprocs,N,NL;
  double *A,*B,*C,*CC;
  double *AL,*BL,*CL,*TEMP;
  MPI_Datatype type_slice1,type_slice2;
  int double_size;
  MPI_Aint lbound,displacement;
  int iter;
  MPI_Status status;
  int previous_rank,following_rank;
  int NLmax,remainder, k, kk, krank;
  int *Ndist, *nbrS, *dispS, *nbrR, *dispR, *position;
  MPI_Datatype *typeS,*typeR;

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

  NL = N/Nprocs;
  NLmax = NL;
  remainder = N%Nprocs;
  NLmax = NLmax+1;
  if (rank < remainder)
    NL=NL+1;
  Ndist = (int *) malloc(Nprocs*sizeof(int));
  MPI_Allgather(&NL,1,MPI_INT,Ndist,1,MPI_INT,MPI_COMM_WORLD);

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
  matrix_allocate(&CL,N,NL);matrix_allocate(&TEMP,NLmax,N);

  /* Processus 0 distribute in AL the horizontal slices of A */
  nbrS = (int *) malloc(Nprocs*sizeof(int));
  dispS = (int *) malloc(Nprocs*sizeof(int));
  typeS = (MPI_Datatype *) malloc(Nprocs*sizeof(MPI_Datatype));

  dispS[0] = 0;
  nbrS[0] = N*Ndist[0];
  for (k=1; k<Nprocs; k++) {
    nbrS[k] = N*Ndist[k];
    dispS[k] = dispS[k-1]+nbrS[k-1]; }
  MPI_Scatterv(A,nbrS,dispS,MPI_DOUBLE,AL,N*NL,MPI_DOUBLE,
              0,MPI_COMM_WORLD);

  /* Processus 0 distribute in BL the vertical slices of B */
  if (rank == 0) {
    for (k=0; k<Nprocs; k++)
      nbrS[k] = 1; }
  else {
    for (k=0; k<Nprocs; k++)
      nbrS[k] = 0; }
  dispS[0] = 0;
  MPI_Type_size(MPI_DOUBLE,&double_size);
  for (k=1; k<Nprocs; k++) {
    dispS[k] = dispS[k-1]+Ndist[k-1]*double_size; }

  MPI_Type_vector(N,NLmax,N,MPI_DOUBLE,&type_slice1);
  MPI_Type_commit(&type_slice1);
  MPI_Type_vector(N,NLmax-1,N,MPI_DOUBLE,&type_slice2);
  MPI_Type_commit(&type_slice2);
  for (k=0; k<Nprocs; k++) {
    if (k < remainder) {
      typeS[k] = type_slice1; }
    else {
      typeS[k] = type_slice2; } }
  nbrR = (int *) malloc(Nprocs*sizeof(int));
  dispR = (int *) malloc(Nprocs*sizeof(int));
  typeR = (MPI_Datatype *) malloc(Nprocs*sizeof(MPI_Datatype));
  nbrR[0] = N*NL;
  dispR[0] = 0;
  typeR[0] = MPI_DOUBLE;
  for (k=1; k<Nprocs; k++) {
    nbrR[k] = 0;
    dispR[k] = 0;
    typeR[k] = MPI_DOUBLE;
  }
  MPI_Alltoallw(B,nbrS,dispS,typeS,BL,nbrR,dispR,typeR,MPI_COMM_WORLD);

  /* Compute position in C */
  position = (int *) malloc((Nprocs+1)*sizeof(int));
  position[0] = 0;
  for (k=1; k<(Nprocs+1); k++) {
    position[k] = position[k-1]+Ndist[k-1]; }

  /* Computation of the diagonal blocks */
  matmul(AL,BL,&(CL[position[rank]*NL]),NL,NL,N);

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
  for (k=0; k<N*NLmax; k++) {
    TEMP[k] = 0; }
  for (k=0; k<N*NL; k++) {
    TEMP[k] = AL[k]; }
  for (iter=1; iter<Nprocs; iter++) {
    // Each process sned his AL slice to his previous process
    // and receives the AL slice from the next process ( the values of AL changed)
    MPI_Sendrecv_replace(TEMP,NLmax*N,MPI_DOUBLE,previous_rank,tag,
                         following_rank,tag,MPI_COMM_WORLD,&status);
    // Each process calculates his block above or below the diagonal block
    krank = (rank+iter)%Nprocs;
    matmul(TEMP,BL,&(CL[position[krank]*NL]),Ndist[krank],NL,N);
  }

  /* The process 0 gather all CL slices from each processes to form the C matrix */
  MPI_Alltoallw(CL,nbrR,dispR,typeR,C,nbrS,dispS,typeS,MPI_COMM_WORLD);

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
  MPI_Type_free(&type_slice1);
  MPI_Type_free(&type_slice2);
  MPI_Finalize();
  return 0;
}
