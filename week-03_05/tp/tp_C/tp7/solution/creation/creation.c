#include <mpi.h>
#include <stdio.h>

int main(int argc, char *argv[]) {
  const int nb_valeurs=242;
  int valeurs[2*nb_valeurs];
  FILE *unit;
  int iter;
  MPI_File descripteur;
  MPI_Status statut;

  MPI_Init(&argc, &argv);

  unit = fopen("carte.dat","r");
  /* Read X Y positions */
  for (iter=0; iter<nb_valeurs; iter++) {
    if (fscanf(unit,"%d %d\n",
               &(valeurs[iter]), &(valeurs[nb_valeurs+iter])) != 2) {
      fprintf(stderr,"Error reading file\n");
      MPI_Abort(MPI_COMM_WORLD,1); }
    };
  fclose(unit);
  /* Values=All X positions then All Y positions */
  MPI_File_set_errhandler(MPI_FILE_NULL,MPI_ERRORS_ARE_FATAL);
  MPI_File_open(MPI_COMM_WORLD,"data.dat",MPI_MODE_RDWR | MPI_MODE_CREATE,
                MPI_INFO_NULL,&descripteur);
  MPI_File_write_all(descripteur,valeurs,2*nb_valeurs,MPI_INT,&statut);
  MPI_File_close(&descripteur);
  MPI_Finalize();
  return 0;
}
