#include <mpi.h>
#include <stdlib.h>
#include <stdio.h>

int main(int argc, char * argv[]) {
  const int nb_values=121;
  int values[nb_values];
  int rank,iter;
  MPI_File fh;
  int nb_bytes_integer;
  MPI_Offset offset;
  MPI_Status status;
  char name_file[256];
  FILE * file;

  MPI_Init( &argc, &argv);
  MPI_Comm_rank(MPI_COMM_WORLD,&rank);
  MPI_File_set_errhandler(MPI_FILE_NULL,MPI_ERRORS_ARE_FATAL);

  /* TODO: Open data.dat in read mode */

  for (iter=0;iter<nb_values; iter++) values[iter]=0;
  /* TODO: Read via explicit offsets, in individual mode */

  sprintf(name_file,"file_dei%1d.dat",rank);
  file = fopen(name_file,"w");
  for (iter=0; iter<nb_values; iter++)
    fprintf(file,"%3d\n",values[iter]);
  fclose(file);
  MPI_Barrier(MPI_COMM_WORLD);
  if (rank == 0)
    printf("First read done\n");

  for (iter=0;iter<nb_values; iter++) values[iter]=0;
  /* TODO: Read via shared ifle pointers, in collective mode */

  sprintf(name_file,"file_ppc%1d.dat",rank);
  file = fopen(name_file,"w");
  for (iter=0; iter<nb_values; iter++)
    fprintf(file,"%3d\n",values[iter]);
  fclose(file);
  MPI_Barrier(MPI_COMM_WORLD);
  if (rank == 0)
    printf("Second read done\n");

  for (iter=0;iter<nb_values; iter++) values[iter]=0;
  /* TODO: Read via individual file pointer, in individual mode */

  sprintf(name_file,"file_pii%1d.dat",rank);
  file = fopen(name_file,"w");
  for (iter=0; iter<nb_values; iter++)
    fprintf(file,"%3d\n",values[iter]);
  fclose(file);
  MPI_Barrier(MPI_COMM_WORLD);
  if (rank == 0)
    printf("Third read done\n");

  for (iter=0;iter<nb_values; iter++) values[iter]=0;
  /* TODO: Read via shared file pointers, in individual mode */

  sprintf(name_file,"file_ppi%1d.dat",rank);
  file = fopen(name_file,"w");
  for (iter=0; iter<nb_values; iter++)
    fprintf(file,"%3d\n",values[iter]);
  fclose(file);
  MPI_Barrier(MPI_COMM_WORLD);
  if (rank == 0)
    printf("Fourth read done\n");

  /* TODO: Close the file */

  MPI_Finalize();
  return 0;
}
