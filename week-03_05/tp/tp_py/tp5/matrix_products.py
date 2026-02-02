import numpy as np
from mpi4py import MPI

tag = 1000

# TODO: Initialize the number of processes -> rank nprocs

if rank == 0:
    # Read the matrix size N from a file
    with open("matrix_products.data", "r") as file:
        N = int(file.readline().strip())

# TODO: Broadcast the matrix size N to all processes

# N need to be divisible by nprocs
if (N % nprocs) != 0:
    print("N {N} is not divisible by nprocs {nprocs}")
    # TODO: Stop the program if N is not divisible by nprocs
  
else:
    NL = N//nprocs

if rank == 0:
    A = np.random.rand(N, N)
    B = np.random.rand(N, N)
    C = np.zeros((N, N), dtype=np.float64)
    CC = np.zeros((N, N), dtype=np.float64)
    # Sequential computation of A*B
    np.matmul(A, B, out=C)
else:
    # Need to be defined to avoid not defined error in scatter & gather
    A = None
    B = None
    C = None
    CC = None

# Initialize the local arrays
AL = np.empty((NL, N), dtype=np.float64)
BL = np.empty((N, NL), dtype=np.float64)
CL = np.empty((N, NL), dtype=np.float64)
TEMP = np.empty((NL, N), dtype=np.float64)

# TODO: Build the datatype for 1 chunk of N lines and NL columns

# TODO: Scatter A to AL and B to BL


# Compute the diagonal blocks
np.matmul(AL, BL, out=CL[rank*NL:(rank+1)*NL, :])
# Compute for non-diagonal blocks
# First algorithm
for iter in range(nprocs):
    if (rank != iter):
        # TODO: Send AL to process k and receive his AL in temp

    # Compute the block above or below the diagonal block
    np.matmul(TEMP, BL, out=CL[iter*NL:(iter+1)*NL, :])
# Second algorithm
# previous_rank = TODO
# following_rank = TODO
# for iter in range(1,nprocs):
#     # TODO: Send AL to previous process and receive from following_rank
#  
#     # Compute the block above or below the diagonal block
#     displacement = (rank+iter) % nprocs
#     np.matmul(AL, BL, out=CL[displacement*NL:(displacement+1)*NL, :])
# TODO: Gather all CL slices to form the C matrix

# Deallocate local arrays
del AL, BL, CL, TEMP
# Verify the results (only process 0 does this)
if rank == 0:
    Emax = 0.0
    Emax = np.max(np.abs(C-CC))
    print(f"Emax = {Emax}")
    if Emax < 1e-10:
        print("Super!")
        print("Matrix product A*B in parallel equal the sequential one")
    else:
        print("False result!")
        print("Matrix product A*B in parallel different from the sequential one")
