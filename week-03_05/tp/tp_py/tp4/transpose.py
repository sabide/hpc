from mpi4py import MPI
import numpy as np

nb_lines = 4
nb_columns = 5
nb_lines_t = nb_columns
nb_columns_t = nb_lines
tag = 1000

# TODO: Get rank -> rank


# Matrices
A = np.zeros((nb_lines, nb_columns))
AT = np.zeros((nb_lines_t, nb_columns_t), dtype=np.float64)

# TODO: Type transpose

if rank == 0:
    # Initialization of matrix A on process 0
    A = np.reshape(np.arange(1, nb_lines * nb_columns + 1, dtype=np.float64),
                   (nb_lines, nb_columns))
    print("Matrix A")
    print(A)
    # TODO: Process 0: Send matrix A to process 1

else:
    # TODO: Process 1: Receive in matrix AT from process 0

    print("Matrix transpose AT")
    print(AT)
