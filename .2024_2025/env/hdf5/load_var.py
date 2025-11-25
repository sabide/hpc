import h5py
import numpy as np

# Nom du fichier HDF5
filename = "field3d.h5"

# Lecture du fichier HDF5
hdf_file=h5py.File(filename, "r")
data = np.array(hdf_file["T"]) # Lecture des données
print("Shape:", data.shape)
print("Data type:", data.dtype)
print("First few values:")
