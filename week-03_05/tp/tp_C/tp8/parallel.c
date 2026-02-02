#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#include <mpi.h>

#include "parallel.h"
#include "params.h"
#include "compute.h"

#define ndims 2 /* grid dimension */
#define NB_NEIGHBOURS 4
#define N 0
#define E 1
#define S 2
#define W 3

/* Local Sub-Domain rank */
int rank;
/* Number of processes */
static int size;
/* Number of processes in each dimension for the Cartesian topology */
static int dims[ndims];
/* Communicator of the Cartesian topology */
static MPI_Comm comm2d;
/* Array storing the rank of neighbours */
static int neighbour[NB_NEIGHBOURS];
/* Derived datatypes */
static MPI_Datatype type_column, type_line;
int ntx, nty;
int sx, ex, sy, ey;

/*
 * Initialization of the MPI environnement
 */
void env_init(int argc, char* argv[]) {
  /* TODO: Get rank and number of processes -> rank, size */

}

/*
 * Creation of the Cartesian topology
 */
void topology_init() {
  FILE *file;
  int periods[ndims];
  const int reorganisation = false;

  /* Read ntx and nty in the file poisson.data */
  file = fopen("poisson.data", "r");
  if (fscanf(file, "%d", &ntx) != 1)
    ntx = 12;
  if (fscanf(file, "%d", &nty) != 1)
    nty = 10;
  fclose(file);

  /* TODO: Number of processes on each dimension -> dims */

  /* TODO: Creation of the 2D Cartesian topology (no periodicity) -> comm2d */

  if (rank == 0) {
    printf("Execution poisson with %d MPI processes\n"
           "Size of the domain: ntx=%d nty=%d\n"
           "Dimension for the topology: %d along x, %d along y\n"
           "-----------------------------------------\n", 
           size, ntx, nty, dims[0], dims[1]);
  }
}

/*
 * Computation of the local grid boundary coordinates (global indexes)
 */
void domain_boundaries() {
  int coords[ndims];
  /* TODO: What is my coordinates in the topology -> coord*/

  /* X-axis limits */
  sx = (coords[0]*ntx)/dims[0]+1;
  ex = ((coords[0]+1)*ntx)/dims[0];

  /* Y-axis limits */
  sy = (coords[1]*nty)/dims[1]+1;
  ey = ((coords[1]+1)*nty)/dims[1];

  printf("Rank in the topology: %d Local Grid Index: %d to %d along x, "
         "%d to %d along y\n", rank, sx, ex, sy, ey);
}

/*
 * Neighbours
 */
void domain_neighbours() {
  /* TODO: Get my northern and southern neighbours -> neighbour[N], neighbour[S] */

  /* TODO: Get my western and eastern neighbours -> neighbour[E], neighbour[W] */

  printf("Process %d neighbour: N %d E %d S %d W %d\n", 
         rank, neighbour[N], neighbour[E], neighbour[S], neighbour[W]);
}

/*
 * Creation of the derived datatypes needed to exchange points with neighbours
 */
void derived_datatypes() {
  /* TODO: Creation of the type_line derived datatype to exchange points
     with northern to southern neighbours */


  /* TODO: Creation of the type_column derived datatype to exchange points
     with western to eastern neighbours */

}

/*
 * IDX(i, j) : indice de l'element i, j dans le tableau u
 * sx-1 <= i <= ex+1
 * sy-1 <= j <= ey+1
 */
#define IDX(i, j) ( ((i)-(sx-1))*(ey-sy+3) + (j)-(sy-1) )
/*
 * Exchange the points at the interface
 */
void communications(double *u) {
  const int tag = 100;
  MPI_Status status;

  /* TODO: Send to neighbour N and receive from neighbour S */

  /* TODO: Send to neighbour S and receive from neighbour N */

  /* TODO: Send to neighbour W and receive from neighbour E */

  /* TODO: Send to neighbour E  and receive from neighbour W */

}

/*
 * Compute the global error (maximum of the locals errors)
 */
double global_error(double *u, double *u_new) {
  double local_error, diffnorm;
  int iterx, itery;

  local_error = 0;
  for (iterx=sx; iterx<ex+1; iterx++) {
    for (itery=sy; itery<ey+1; itery++) {
      double temp = fabs( u[IDX(iterx, itery)] - u_new[IDX(iterx, itery)] );
      if (local_error < temp) local_error = temp;
    }
  }
  /* TODO: Computation of global error */

  return diffnorm;
}

/*
 * Write array u inside a domain for each process in the data.dat file
 */
void write_data(double *u) {
  MPI_File fh;
  int shape_array[ndims], shape_subarray[ndims], start_coord[ndims];
  int shape_array_view[ndims], shape_subarray_view[ndims], start_coord_view[ndims];
  MPI_Datatype type_subarray, type_subarray_view;
  MPI_Offset initial_displacement;
  MPI_Status status;

  /* TODO: Change the error handler for file */

  /* TODO: Open file "data.dat" in write mode */

  /* TODO: Change the file view */

  /* TODO: Creation of the derived datatype type_subarray corresponding to the matrix u without ghost cells */

  /* TODO: Write u for each process with the view */

  /* TODO: Close file */

  /* TODO: Clean MPI types */

}

/*
 * Terminates MPI execution environment
 */
void env_finalize() {
  /* TODO: Clean MPI objects */

  /* TODO: Terminates MPI execution environment */

}
