#include <stdlib.h>
#include <stdio.h>

#include <mpi.h>

int main(int argc, char *argv[]) {
  int rank;
  int ntx, nty;
  FILE *file;
  double *u;
  int iter;
  MPI_File fh;
  int code;
  MPI_Status status;
  MPI_Offset file_size;
  int double_size;
  int text_length;
  char text_error[MPI_MAX_ERROR_STRING];

  MPI_Init(&argc, &argv);

  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  file = fopen("poisson.data", "r");
  if (fscanf(file, "%d", &ntx) != 1)
    ntx = 12;
  if (fscanf(file, "%d", &nty) != 1)
    nty = 10;
  fclose(file);

  u = malloc(ntx*nty*sizeof(double));
  for (iter=0; iter<ntx*nty; iter++)
    u[iter] = 0.;

  code = MPI_File_open(MPI_COMM_WORLD, "data.dat", MPI_MODE_RDONLY, 
   MPI_INFO_NULL, &fh);
  if (code != MPI_SUCCESS) {
    MPI_Error_string(code, text_error, &text_length);
    printf("%s\n", text_error);
    MPI_Abort(MPI_COMM_WORLD,42);
  }

  MPI_File_set_errhandler(MPI_FILE_NULL,MPI_ERRORS_ARE_FATAL);
  MPI_File_get_size(fh, &file_size);
  MPI_Type_size(MPI_DOUBLE, &double_size);
  if (file_size != ntx*nty*double_size) {
    printf("ATTENTION data.dat does not have the good size\n");
    printf("Size of the file : %lld\n", file_size);
    printf("Size wanted : %d\n", ntx*nty*double_size);
  } else {
    file = fopen("fort.11", "w");
    MPI_File_read(fh, u, ntx*nty, MPI_DOUBLE, &status);
    for (iter=0; iter<ntx*nty; iter++) {
      fprintf(file, "%12.5e\n", u[iter]); }
    fclose(file);
  }

  MPI_File_close(&fh);

  free(u);

  MPI_Finalize();
  return 0;
}
