from mpi4py import MPI
import math

# Initialisation de la bibliothèque MPI
comm = MPI.COMM_WORLD
rank = comm.Get_rank()
nb_procs = comm.Get_size()

# Interval number
nbblock = 3 * 1000 * 1000 * 100
# Interval width
width = 1.0 / nbblock

local_sum = 0.0

# Progressive distribution
begin = (rank * nbblock) // nb_procs + 1
end = ((rank + 1) * nbblock) // nb_procs

# Remainder are distributed on the first rank
# begin = rank * (nbblock // nb_procs) + 1 + min(rank, nbblock % nb_procs)
# end = begin + (nbblock // nb_procs) - 1
# if rank < nbblock % nb_procs:
#  end += 1

# Remainder are distributed on the last rank
# begin = rank * (nbblock // nb_procs) + 1 + \
# max(nbblock % nb_procs + rank - nb_procs, 0)
# end = begin + (nbblock + rank) // nb_procs - 1

print(f"{rank} begin: {begin} end: {end} delta: {end-begin+1}")

# Compute local sum
for i in range(begin, end + 1):
    x = width * (i - 0.5)
    local_sum += width * (4.0 / (1.0 + x * x))

global_sum = comm.reduce(local_sum, op=MPI.SUM)

if rank == 0:
    print(f"Pi = {global_sum}")
    print(f"Difference = {global_sum - 4.0 * math.atan(1.0)}")

nb_iterations = comm.reduce(end - begin + 1, op=MPI.SUM)

if rank == 0:
    print(f"Nb = {nb_iterations}")
