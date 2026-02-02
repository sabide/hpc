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
  /* MPI initialization */
  MPI_Init(&argc, &argv);

  /* Who I am */
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);

  /* Total number of processes */
  MPI_Comm_size(MPI_COMM_WORLD, &size);
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

  /* Number of processes on each dimension (depends on the total number of processes) */
  dims[0] = dims[1] = 0;
  MPI_Dims_create(size, ndims, dims);

  /* Creation of the 2D Cartesian topology (no periodicity) */
  periods[0] = periods[1] = false;
  MPI_Cart_create(MPI_COMM_WORLD, ndims, dims, periods, reorganisation, &comm2d);

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
  /* What is my coordinates in the topology */
  MPI_Cart_coords(comm2d, rank, ndims, coords);

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
  /* Get my northern and southern neighbours */
  MPI_Cart_shift(comm2d, 0, 1, &(neighbour[N]), &(neighbour[S]));

  /* Get my western and eastern neighbours */
  MPI_Cart_shift(comm2d, 1, 1, &(neighbour[W]), &(neighbour[E]));

  printf("Process %d neighbour: N %d E %d S %d W %d\n", 
         rank, neighbour[N], neighbour[E], neighbour[S], neighbour[W]);
}

/*
 * Creation of the derived datatypes needed to exchange points with neighbours
 */
void derived_datatypes() {
  /* Creation of the type_line derived datatype to exchange points
     with northern to southern neighbours */
  MPI_Type_contiguous(ey-sy+1, MPI_DOUBLE, &type_line);
  MPI_Type_commit(&type_line);

  /* Creation of the type_column derived datatype to exchange points
     with western to eastern neighbours */
  MPI_Type_vector(ex-sx+1, 1, ey-sy+3, MPI_DOUBLE, &type_column);
  MPI_Type_commit(&type_column);
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

  /* Send to neighbour N and receive from neighbour S */
  MPI_Sendrecv(&(u[IDX(sx, sy)]), 1, type_line, neighbour[N], tag, 
               &(u[IDX(ex+1, sy)]), 1, type_line, neighbour[S], tag, 
               comm2d, &status);

  /* Send to neighbour S and receive from neighbour N */
  MPI_Sendrecv(&(u[IDX(ex, sy)]), 1, type_line, neighbour[S], tag, 
               &(u[IDX(sx-1, sy)]), 1, type_line, neighbour[N], tag, 
               comm2d, &status);

  /* Send to neighbour W  and receive from neighbour E */
  MPI_Sendrecv(&(u[IDX(sx, sy)]), 1, type_column , neighbour[W], tag, 
               &(u[IDX(sx, ey+1)]), 1, type_column , neighbour[E], tag, 
               comm2d, &status);

  /* Send to neighbour E  and receive from neighbour W */
  MPI_Sendrecv(&(u[IDX(sx, ey)]), 1, type_column, neighbour[E], tag, 
               &(u[IDX(sx, sy-1)]), 1, type_column, neighbour[W], tag, 
               comm2d, &status);
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
  /* Computation of global error */
  MPI_Allreduce(&local_error, &diffnorm, 1, MPI_DOUBLE, MPI_MAX, comm2d);

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

  /* Change the error handler for file */
  MPI_File_set_errhandler(MPI_FILE_NULL,MPI_ERRORS_ARE_FATAL);
  /* Open file "data.dat" in write mode */
  MPI_File_open(comm2d, "data.dat", MPI_MODE_WRONLY | MPI_MODE_CREATE, 
                MPI_INFO_NULL, &fh);

  /* Creation of the derived datatype type_subarray_view for the view on the file */
  /* Shape of the array */
  shape_array_view[0] = ntx;
  shape_array_view[1] = nty;

  /* Shape of the subarray */
  shape_subarray_view[0] = ex-sx+1;
  shape_subarray_view[1] = ey-sy+1;

  /* Starting coordinates of the subarray */
  start_coord_view[0] = sx-1;
  start_coord_view[1] = sy-1;

 /* Creation of the derived datatype type_subarray_view */
  MPI_Type_create_subarray(ndims, shape_array_view, shape_subarray_view, start_coord_view, 
                           MPI_ORDER_C, MPI_DOUBLE, &type_subarray_view);

  /* Commit type_subarray_view */
  MPI_Type_commit(&type_subarray_view);

  /* Change the file view */
  initial_displacement = 0;
  MPI_File_set_view(fh, initial_displacement, MPI_DOUBLE, 
                    type_subarray_view, "native", MPI_INFO_NULL);

  /* Creation of the derived datatype type_subarray corresponding to the matrix u without ghost cells */
  /* Shape  of the array */
  shape_array[0] = ex-sx+3;
  shape_array[1] = ey-sy+3;

  /* Shape of the subarray */
  shape_subarray[0] = ex-sx+1;
  shape_subarray[1] = ey-sy+1;

  /* Starting coordinate of the subarray */
  start_coord[0] = 1;
  start_coord[1] = 1;

  /* Creation of the derived datatype type_subarray */
  MPI_Type_create_subarray(ndims, shape_array, shape_subarray, start_coord, 
                           MPI_ORDER_C, MPI_DOUBLE, &type_subarray);

  /* Commit type_subarray */
  MPI_Type_commit(&type_subarray);

  /* Write u for each process with the view */
  MPI_File_write_all(fh, u, 1, type_subarray, &status);

  /* Close file */
  MPI_File_close(&fh);

  /* Clean MPI types */
  MPI_Type_free(&type_subarray_view);
  MPI_Type_free(&type_subarray);
}

/*
 * Terminates MPI execution environment
 */
void env_finalize() {
  /* Clean MPI objects */
  MPI_Comm_free(&comm2d);
  MPI_Type_free(&type_column);
  MPI_Type_free(&type_line);
  /* Terminates MPI execution environment */
  MPI_Finalize();
}
