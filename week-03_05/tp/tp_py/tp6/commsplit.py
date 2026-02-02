from mpi4py import MPI
import numpy as np

# Get rank & size
comm = MPI.COMM_WORLD
size = comm.Get_size()
rank = comm.Get_rank()

dimCart2D = [4, 2]

if dimCart2D[0]*dimCart2D[1] != size:
    print("The number of processes is not correct!")
    # TODO: Abort the program

# TODO: Create a 2D cartesian topology -> commCart2D

# TODO: Get the rank and coordinates in the 2D cartesian topology -> coordCart2D

# Initialize the array v and w
if (coordCart2D[0] == 1):
    v = np.array([1, 2, 3, 4], dtype=np.float64)
else:
    v = None
w = np.zeros(1, dtype=np.float64)

# TODO: Subdividing the 2D cartesian topology with SPLIT

# TODO: Scatter using this new communicator


print(f"Rang : {rank} ; Coordinates ({coordCart2D[0]}, {coordCart2D[1]}) "
      f"; w = {w}")
