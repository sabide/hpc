#include <stdio.h>
#include <math.h>
#include <mpi.h>

#define MAX(a,b) ((a) > (b) ? a : b)
#define MIN(a,b) ((a) < (b) ? a : b)

int main(int argc, char *argv[]) {
  long long nbblock,i;
  double width, sum, x;
  int rank,nb_procs;
  long long begin,end;
  double global;

  MPI_Init(&argc, &argv);
  MPI_Comm_rank(MPI_COMM_WORLD,&rank);
  MPI_Comm_size(MPI_COMM_WORLD,&nb_procs);

  /* Interval number */
  nbblock = 3*1000*1000LL*100;
  /* Interval width */
  width = 1.0/nbblock;

  sum = 0;

  /* Progressive distribution */
  /* rang*nbbloc must be less than 9.10^18 */
  begin = (rank*nbblock)/nb_procs;
  end = ((rank+1)*nbblock)/nb_procs;

  /* Idem */
  /* rang*nbbloc must be less than  9.10^15 */
  /*begin = ((1.0*rank)*nbblock)/nb_procs;
    end = ((1.0*(rank+1))*nbblock)/nb_procs;*/

  /* Remainder are distributed on the first rank */
  /*begin = rank*(nbblock/nb_procs)+MIN(rank,nbblock%nb_procs);
    end = begin+(nbblock/nb_procs);
    if (rank < (nbblock%nb_procs)) end++;*/

  /* Remainder are distributed on the last rank */
  /*begin = rank*(nbblock/nb_procs)+MAX((nbblock%nb_procs)+rank-nb_procs,0);
    end = begin+(nbblock+rank)/nb_procs;*/

  printf("%d begin: %lld end: %lld delta: %lld\n", rank, begin, end, end-begin);

  for (i=begin; i<end; i++) {
    /* Point in the middle of the interval */
    x = width*(i+0.5);
    /* Compute the area */
    sum = sum + width*(4.0 / (1.0 + x*x));
  }

  MPI_Reduce(&sum, &global, 1, MPI_DOUBLE, MPI_SUM, 0, MPI_COMM_WORLD);
  if (rank ==0) printf("Pi = %.12lf\n", global);
  if (rank ==0) printf("Difference = %g\n", global-4.0*atan(1.0));
  i = end-begin;
  MPI_Allreduce(MPI_IN_PLACE,&i,1,MPI_LONG_LONG, MPI_SUM, MPI_COMM_WORLD);
  if (rank ==0) printf("Nb = %lld\n", i);

  MPI_Finalize();
  return 0;
}
