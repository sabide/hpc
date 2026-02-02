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
    /* TODO: We stop the program */

  }
  periods[0] = no; periods[1] = no;
  reorder = no;

  /* TODO: Creation of commcart2D comunicator (2D cartesian topology) */

  /* TODO: Get the coordinates of the current process */

  /* Initialization of V array and W scalar */
  w = v[0] = v[1] = v[2] = v[3] = 0;
  if (coordCart2D[0] == 1) {
    v[0] = 1; v[1] = 2; v[2] = 3; v[3] = 4; }

  /* TODO: Subdividing the 2D cartesian topology with MPI_COMM_SPLIT */

  /* TODO: Process of the second column scatters the V array
   * to each process of their line */

  printf("rank : %2d ; Coordinates ( %1d , %1d ) ; W = %2f\n",
         rank, coordCart2D[0], coordCart2D[1], w);

  MPI_Comm_free(&commCart1D);
  MPI_Comm_free(&commCart2D);
  MPI_Finalize();
  return 0;
}

