#include "mpi.h"
#include <stdlib.h>
#include <stdio.h>

int main(int argc, char *argv[]) {
  int rank,iter;
  int nb_values=1000;
  int tag=99;
  double values[nb_values];
  MPI_Status status;
  double time_begin,time_end;

  /* TODO : Get rank */

  if (rank == 0) {
    for (iter = 0; iter<nb_values; iter++)
      values[iter] = rand() / (RAND_MAX + 1.);
    /* TODO : Get starting time -> time_begin */
    
    /* TODO : Process 0 send and receive values with process 1 */

    /* TODO : Get ending time -> time_end */

    printf("Me, process 0, sent and received %d values"
           "(last = %g) from process 1 in %f seconds.\n",
           nb_values, values[nb_values-1], time_end-time_begin);
  else {
    /* TODO : Process 1 receive values and send them with process 0 */

  }

  /* TODO : Finalize MPI */
  
  return 0;
}
