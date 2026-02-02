from mpi4py import MPI
import numpy as np

# Get rank -> rank
comm = MPI.COMM_WORLD
rank = comm.Get_rank()

nb_values = 1000
tag = 99

# Create an array of double precision values
values = np.zeros(nb_values, dtype=np.float64)

# Seed the random number generator for reproducibility
np.random.seed(42)

if rank == 0:
    # Fill the array with random numbers on process 0
    values = np.random.rand(nb_values)
    # Begin the timing of the ping pong -> time_begin
    time_begin = MPI.Wtime()
    # Process 0: Send and recv with process 1
    comm.Send(values, dest=1, tag=tag)
    comm.Recv(values, source=1, tag=tag)
    # End timing -> time_end
    time_end = MPI.Wtime()
    print(f"Me, process 0, sent and received {nb_values} "
          f"values (last = {values[-1]:.2f}) from process 1 in "
          f"{time_end - time_begin:.6f} seconds.")
elif rank == 1:
    # Process 1: recv and send with process 0
    comm.Recv(values, source=0, tag=tag)
    comm.Send(values, dest=0, tag=tag)
