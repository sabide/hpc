from mpi4py import MPI
import numpy as np

# TODO: Get rank -> rank



nb_values = 1000
tag = 99

# Create an array of double precision values
values = np.zeros(nb_values, dtype=np.float64)

# Seed the random number generator for reproducibility
np.random.seed(42)

    # Fill the array with random numbers on process 0
    values = np.random.rand(nb_values)
    # TODO: Begin the timing of the ping pong -> time_begin

    # TODO: Process 0: Send and recv with process 1

    # TODO: End timing -> time_end

    print(f"Me, process 0, sent and received {nb_values} "
          f"values (last = {values[-1]:.2f}) from process 1 in "
          f"{time_end - time_begin:.6f} seconds.")

    # TODO: Process 1: recv and send with process 0
