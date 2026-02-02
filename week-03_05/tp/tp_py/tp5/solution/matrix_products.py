import numpy as np
from mpi4py import MPI

tag = 1000
# Define the communicator
comm = MPI.COMM_WORLD

# Initialize the number of processes -> rank nprocs
nprocs = comm.Get_size()
rank = comm.Get_rank()

if rank == 0:
    # Read the matrix size N from a file
    with open("matrix_products.data", "r") as file:
        N = int(file.readline().strip())

# Broadcast the matrix size N to all processes
if rank != 0:
    # Otherwise error "N is not defined" in bcast
    N = None
N = comm.bcast(N, root=0)
# print(f"After bcast N={N} on {rank}")

# N need to be divisible by nprocs
if (N % nprocs) != 0:
    print("N {N} is not divisible by nprocs {nprocs}")
    # Stop the program if N is not divisible by Nprocs
    comm.Abort()
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

# Build the datatype for 1 chunk of N lines and NL columns
type_temp = MPI.DOUBLE.Create_vector(N, NL, N)
extent = MPI.DOUBLE.Get_size() * NL
type_slice = type_temp.Create_resized(0, extent)
type_slice.Commit()

# Scatter A to AL and B to BL
comm.Scatter(sendbuf=[A, N*NL, MPI.DOUBLE], recvbuf=[AL, N*NL, MPI.DOUBLE],
             root=0)
comm.Scatter([B, 1, type_slice], [BL, N*NL, MPI.DOUBLE], root=0)
# Compute the diagonal blocks
np.matmul(AL, BL, out=CL[rank*NL:(rank+1)*NL, :])
# Compute for non-diagonal blocks
# First algorithm
# for iter in range(nprocs):
#    if (rank != iter):
#        #print(f"rank {rank} iter {iter}")
#        # Send AL to process k and receive his AL in temp
#        comm.Sendrecv(sendbuf=[AL,N*NL,MPI.DOUBLE], dest=iter, sendtag=tag,
#                      recvbuf=[TEMP,N*NL,MPI.DOUBLE], source=iter, recvtag=tag)
#    # Compute the block above or below the diagonal block
#    np.matmul(TEMP, BL, out=CL[iter*NL:(iter+1)*NL,:])
# Second algorithm
previous_rank = (nprocs+rank-1) % nprocs
following_rank = (rank+1) % nprocs
for iter in range(1, nprocs):
    # Send AL to previous process and receive from following_rank
    comm.Sendrecv_replace(buf=[AL, N*NL, MPI.DOUBLE],
                          dest=previous_rank, sendtag=tag,
                          source=following_rank, recvtag=tag)
    # Compute the block above or below the diagonal block
    displacement = (rank+iter) % nprocs
    np.matmul(AL, BL, out=CL[displacement*NL:(displacement+1)*NL, :])
# Gather all CL slices to form the C matrix
comm.Gather([CL, N*NL, MPI.DOUBLE], [CC, 1, type_slice], root=0)
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
