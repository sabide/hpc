/*
 * ping_pong_3.c   --- TP3 : point-to-point communications :
 *                           ping-pong for differents size of messages
 *
 * Author          : Dimitri LECAS (CNRS/IDRIS - France) <dimitri.lecas@idris.fr>
 *
*/

#include "mpi.h"
#include <stdlib.h>
#include <stdio.h>


int main(int argc, char *argv[]) {
  int rank,iter,iter2;
  int nb_tests=10;
  int nb_values[nb_tests];
  int nb_values_max=7000000;
  int tag=99;
  double *values;
  MPI_Status status;
  double time_begin,time_end;

  /* TODO : Get rank */

  nb_values[0]=0,nb_values[1]=0,nb_values[2]=1,nb_values[3]=10;
  nb_values[4]=100,nb_values[5]=1000,nb_values[6]=10000;
  nb_values[7]=100000,nb_values[8]=1000000,nb_values[9]=7000000;
  values = (double *) malloc(nb_values_max*sizeof(double));

  for(iter=0; iter<nb_tests; iter++) {
    if (rank == 0) {
      for (iter2 = 0; iter2<nb_values_max; iter2++)
        values[iter2] = rand() / (RAND_MAX + 1.);
      /* TODO: Get starting time -> time_begin */
      
      /* TODO: Process 0 sends and receives values from process 1 */

      /* TODO: Get ending time -> time_end */

      if (nb_values[iter] != 0) {
        printf("Me, process 0, sent and received %8d values"
               "(last = %4.2f) from process 1 in %8.6f seconds, bandwidth "
               "%7.2f MB/s.\n",
               nb_values[iter], values[nb_values[iter]-1],
               time_end-time_begin,
               2.*nb_values[iter]*8/1000000./(time_end-time_begin));
      } else
        printf("Me, process 0, sent and received %8d values in %8.6f "
               "seconds, bandwidth %7.2f MB/s.\n",
               nb_values[iter], time_end-time_begin,
               2.*nb_values[iter]*8/1000000./(time_end-time_begin));
    } else if(rank == 1) {
      /* TODO: Process 1 receives values from process 0 */

    }
  }

  /* TODO: Finaliser MPI */
  
  return 0;
}
