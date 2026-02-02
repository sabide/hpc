from mpi4py import MPI
import numpy as np

# Parameters
nb_values = 1000
tag = 99

# Initialize MPI & get the rank of the process
comm = MPI.COMM_WORLD
rank = comm.Get_rank()

# Create an array of double precision values
values = np.zeros(nb_values, dtype=np.float64)

# Seed the random number generator for reproducibility
np.random.seed(42)

if rank == 0:
    # Fill the array with random numbers
    values = np.random.rand(nb_values)
    # Process 0 sends the values to process 1
    comm.Send(values, dest=1, tag=tag)
elif rank == 1:
    # Process 1 receives the values from process 0
    comm.Recv(values, source=0, tag=tag)
    print(f"Me, process 1, received {nb_values} "
          f"values (last = {values[-1]:.2f}) from process 0.")
