from mpi4py import MPI

# MPI_Init() is done at the import

comm = MPI.COMM_WORLD
rank = comm.Get_rank()
size = comm.Get_size()

if rank % 2 == 0:
    print(f'I am the even-ranked process my rank is {rank}')
else:
    print(f'I am the odd-ranked process my rank is {rank}')

# MPI_Finalize() is done at exit
