from mpi4py import MPI
import numpy as np

nb_lines = 4
nb_columns = 5
nb_lines_t = nb_columns
nb_columns_t = nb_lines
tag = 1000

# Get rank and size -> rank & size
comm = MPI.COMM_WORLD
rank = comm.Get_rank()
size = comm.Get_size()

# Matrices
A = np.zeros((nb_lines, nb_columns))
AT = np.zeros((nb_lines_t, nb_columns_t), dtype=np.float64)
float_mpi = MPI.DOUBLE

# Type column for AT
type_column = float_mpi.Create_vector(nb_lines_t, 1, nb_columns_t)
size_displacement = float_mpi.Get_size()
# Type transpose for AT
type_transpose = type_column.Create_resized(0, size_displacement)
# Validation of the derived datatypes type_transpose
type_transpose.Commit()

if rank == 0:
    # Initialization of matrix A on process 0
    A = np.reshape(np.arange(1, nb_lines * nb_columns + 1, dtype=np.float64),
                   (nb_lines, nb_columns))
    print("Matrix A")
    print(A)
    # Process 0: Send matrix A to process 1
    comm.Send([A, nb_columns*nb_lines, MPI.DOUBLE], dest=1, tag=tag)
else:
    # Process 1: Receive in matrix AT from process 0
    comm.Recv([AT, nb_columns_t, type_transpose], source=0, tag=tag)
    print("Matrix transpose AT")
    print(AT)
