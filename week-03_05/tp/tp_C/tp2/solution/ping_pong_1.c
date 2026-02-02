#include "mpi.h"
#include <stdlib.h>
#include <stdio.h>

int main(int argc, char *argv[]) {
  int rank,iter;
  int nb_values=1000;
  int tag=99;
  double values[nb_values];
  MPI_Status status;

  MPI_Init( &argc, &argv);
  MPI_Comm_rank( MPI_COMM_WORLD, &rank);

  if (rank == 0) {
    for (iter = 0; iter<nb_values; iter++)
      values[iter] = rand() / (RAND_MAX + 1.);
    MPI_Send(values,nb_values,MPI_DOUBLE,1,tag,MPI_COMM_WORLD);
  } else if(rank == 1) {
    MPI_Recv(values,nb_values,MPI_DOUBLE,0,tag,MPI_COMM_WORLD,&status);
    printf("Me, process 1, received %d values (last = %g)"
           "from process 0.\n", nb_values, values[nb_values-1]);
  }

  MPI_Finalize();
  return 0;
}
