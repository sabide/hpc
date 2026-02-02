from mpi4py import MPI
import numpy as np

# Parameters
nb_values = 1000
tag = 99

# TODO: Initialize MPI & get the rank of the process

# Create an array of double precision values
values = np.zeros(nb_values, dtype=np.float64)

# Seed the random number generator for reproducibility
np.random.seed(42)

    # Fill the array with random numbers on process 0
    values = np.random.rand(nb_values)
    # TODO: Process 0 sends the values to process 1


    # TODO: Process 1 receives the values from process 0

    print(f"Me, process 1, received {nb_values} "
          f"values (last = {values[-1]:.2f}) from process 0.")
