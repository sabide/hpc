from mpi4py import MPI
import numpy as np

# Get rank & size
comm = MPI.COMM_WORLD
size = comm.Get_size()
rank = comm.Get_rank()

dimCart2D = [4, 2]

if dimCart2D[0]*dimCart2D[1] != size:
    print("The number of processes is not correct!")
    # Abort the program
    comm.Abort(errorcode=1)
# Create a 2D cartesian topology -> commCart2D
commCart2D = comm.Create_cart(dimCart2D)
# Get the rank and coordinates in the 2D cartesian topology
rank = commCart2D.Get_rank()
coordCart2D = commCart2D.Get_coords(rank)

# Initialize the array v and w
if (coordCart2D[0] == 1):
    v = np.array([1, 2, 3, 4], dtype=np.float64)
else:
    v = None
w = np.zeros(1, dtype=np.float64)

# Subdividing the 2D cartesian topology with SPLIT
commCart1D = commCart2D.Split(color=coordCart2D[1])
# Scatter using this new communicator
commCart1D.Scatter(sendbuf=[v, 1, MPI.DOUBLE],
                   recvbuf=[w, 1, MPI.DOUBLE], root=1)

print(f"Rang : {rank} ; Coordinates ({coordCart2D[0]}, {coordCart2D[1]}) "
      f"; w = {w}")
