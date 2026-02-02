#include "mpi.h"
#include <stdlib.h>
#include <stdio.h>

int main(int argc, char *argv[]) {
  int nb_lines=4;
  int nb_columns=5;
  int nb_lines_t=5;
  int nb_columns_t=4;
  int tag=1000;
  double a[nb_lines][nb_columns];
  double at[nb_lines_t][nb_columns_t];
  int rank,iterl,iterc,size_real;
  MPI_Datatype type_column, type_transpose;
  MPI_Aint size_displacement;
  MPI_Status status;

  /* TODO: Get rank -> rank */

  /* TODO: Type_transpose */

  if (rank == 0) {
    /* Initialisation of A */
    for (iterl=0; iterl<nb_lines; iterl++)
      for (iterc=0; iterc<nb_columns; iterc++)
        a[iterl][iterc] = 1+iterl*nb_columns+iterc;
    printf("Matrix a\n");
    for (iterl=0; iterl<nb_lines;iterl++) {
      for (iterc=0; iterc<nb_columns; iterc++) {
        printf("%4.f ", a[iterl][iterc]);
      }
      printf("\n");
    }

    /* TODO: Send matrix A to process 1 */

  } else {
    /* TODO: Receive in matrix AT with type_transpose */

    printf("Matrice transposee at\n");
    for (iterc=0; iterc<nb_lines_t; iterc++) {
      for (iterl=0; iterl<nb_columns_t;iterl++) {
        printf("%4.f ", at[iterc][iterl]);
      }
      printf("\n");
    }
  }

  /* TODO: Clean MPI types */

  /* TODO: Finalize MPI */

  return 0;
}
