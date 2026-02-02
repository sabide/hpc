#include "mpi.h"
#include <stdio.h>

int main(int argc, char *argv[]) {
  int rank, nb_procs;

  MPI_Init( &argc, &argv);

  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &nb_procs);

  if ( (rank % 2) == 0)
    printf("I am the even-ranked process my rank is %d\n", rank);
  else
    printf("I am the odd-ranked process my rank is %d\n", rank);

  MPI_Finalize();
  return 0;
}
