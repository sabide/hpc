from mpi4py import MPI
import numpy as np

nb_values = 121
values = np.zeros(nb_values, dtype=np.int32)

comm = MPI.COMM_WORLD
rank = comm.Get_rank()

# Open data.dat in read mode
fh = MPI.File.Open(comm, "data.dat", MPI.MODE_RDONLY)

# Read via explicit offsets, in individual mode
nb_bytes_integer = MPI.INT.Get_size()
offset = rank * nb_values * nb_bytes_integer
fh.Read_at(offset, [values, nb_values, MPI.INT])
filename = f"file_dei{rank}.dat"
np.savetxt(filename, values, fmt='%3d')
if rank == 0:
    print(f"First read done")

values = np.zeros(nb_values, dtype=np.int32)
# Read via shared file pointers in collective mode
fh.Read_ordered([values, nb_values, MPI.INT])
filename = f"file_ppc{rank}.dat"
np.savetxt(filename, values, fmt='%3d')
if rank == 0:
    print(f"Second read done")

values = np.zeros(nb_values, dtype=np.int32)
# Read via individual file pointer, in individual mode
fh.Seek(offset, MPI.SEEK_SET)
fh.Read([values, nb_values, MPI.INT])
filename = f"file_pii{rank}.dat"
np.savetxt(filename, values, fmt='%3d')
if rank == 0:
    print(f"Third read done")

values = np.zeros(nb_values, dtype=np.int32)
# Read via shared file pointers, in individual mode
fh.Seek_shared(0, MPI.SEEK_SET)
fh.Read_shared([values, nb_values, MPI.INT])
filename = f"file_ppi{rank}.dat"
np.savetxt(filename, values, fmt='%3d')
if rank == 0:
    print(f"Fourth read done")

# Fermer le fichier
fh.Close()
