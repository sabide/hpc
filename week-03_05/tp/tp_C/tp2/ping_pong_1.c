#include "mpi.h"
#include <stdlib.h>
#include <stdio.h>

int main(int argc, char *argv[]) {
  int rank,iter;
  int nb_values=1000;
  int tag=99;
  double values[nb_values];
  MPI_Status status;

  /* TODO: Init MPI & get rank */

  if (rank == 0) {
    for (iter = 0; iter<nb_values; iter++)
      values[iter] = rand() / (RAND_MAX + 1.);
    /* TODO: Process 0 send values to process 1 */
  } else if(rank == 1) {
    /* TODO: Process 1 receive values from process 0 */

    printf("Me, process 1, received %d values (last = %g)"
           "from process 0.\n", nb_values, values[nb_values-1]);
  }

  /* TODO: Finalize MPI */
  
  return 0;
}
