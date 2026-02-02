from mpi4py import MPI
import numpy as np

# Parameters
nb_values_max = 7000000
nb_tests = 10
tag = 99

# TODO: Get rank -> rank


# Values array
values = np.zeros(nb_values_max, dtype=np.float64)

# List of messages sizes to test
nb_values = [0, 0, 1, 10, 100, 1000, 10000, 100000, 1000000, 7000000]

for nb_value in nb_values:
    # Do a ping for each size

        values = np.random.rand(nb_values_max)
        # TODO: Begin the timing of the ping pong -> time_begin

        # TODO: Process 0: Send and recv with process 1

        # TODO: End the timing of the ping pong -> time_end

        bandwidth = (2 * nb_value * 8) / 1000000 / (time_end - time_begin)
        if nb_value != 0:
            print(f"Me, process 0, sent and received {nb_value} "
                  f"values (last = {values[nb_value - 1]:.2f}) "
                  f"from process 1 in {time_end - time_begin:.6f} seconds,"
                  f" bandwidth {bandwidth:.2f} Mo/s.")
        else:
            print(f"Me, process 0, sent and received {nb_value} "
                  f"values in {time_end - time_begin:.6f} seconds, "
                  f"bandwidth {bandwidth:.2f} Mo/s.")

        # TODO: Process 1: Recv and send with process 0
