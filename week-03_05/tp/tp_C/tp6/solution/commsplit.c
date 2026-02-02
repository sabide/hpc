#include <mpi.h>
#include <stdlib.h>
#include <stdio.h>

int main(int argc, char *argv[]) {
  int nb_procs,rank;
  const int nDimCart2D=2;
  int dimCart2D[nDimCart2D];
  int periods[nDimCart2D];
  const int no=0;
  int reorder;
  MPI_Comm commCart2D,commCart1D;
  int coordCart2D[nDimCart2D];
  const int m=4;
  double v[m];
  double w;

  MPI_Init( &argc, &argv);
  MPI_Comm_rank(MPI_COMM_WORLD,&rank);
  MPI_Comm_size(MPI_COMM_WORLD, &nb_procs);

  dimCart2D[0] = 4;
  dimCart2D[1] = 2;
  if (dimCart2D[0]*dimCart2D[1] != nb_procs) {
    fprintf(stderr, "The number of processes is not correct !");
    /* We stop the program */
    MPI_Abort(MPI_COMM_WORLD,1);
  }
  periods[0] = no; periods[1] = no;
  reorder = no;

  /* Creation of commcart2D comunicator (2D cartesian topology) */
  MPI_Cart_create(MPI_COMM_WORLD,nDimCart2D,dimCart2D, periods, reorder,
                  &commCart2D);
  MPI_Comm_rank(commCart2D,&rank);
  MPI_Cart_coords(commCart2D,rank,nDimCart2D,coordCart2D);

  /* Initialization of V array and W scalar */
  w = v[0] = v[1] = v[2] = v[3] = 0;
  if (coordCart2D[0] == 1) {
    v[0] = 1; v[1] = 2; v[2] = 3; v[3] = 4; }

  /* Subdividing the 2D cartesian topology with MPI_COMM_SPLIT */
  MPI_Comm_split( commCart2D, coordCart2D[1], rank, &commCart1D);

  /* Process of the second column scatters the V array
   * to each process of their line */
  MPI_Scatter(v,1,MPI_DOUBLE,&w,1,MPI_DOUBLE,1,commCart1D);

  printf("rank : %2d ; Coordinates ( %1d , %1d ) ; W = %2f\n",
         rank, coordCart2D[0], coordCart2D[1], w);

  MPI_Comm_free(&commCart1D);
  MPI_Comm_free(&commCart2D);
  MPI_Finalize();
  return 0;
}

