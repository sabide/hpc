import numpy as np
import matplotlib.pyplot as plt

# ---------------------------------------------------
# Paramètres (doivent matcher le code Fortran)
# ---------------------------------------------------
nx = 501
ny = 51
Lx = 10.0
Ly = 1.0

# ---------------------------------------------------
# Lecture du fichier Fortran
# ---------------------------------------------------
data = np.loadtxt("p_final.dat")   # x, y, p

x_flat = data[:, 0]
y_flat = data[:, 1]
p_flat = data[:, 2]

# Remise en forme (ny, nx) car Fortran a bouclé j (y) puis i (x)
X = x_flat.reshape(ny, nx)
Y = y_flat.reshape(ny, nx)
P = p_flat.reshape(ny, nx)

# ---------------------------------------------------
# Plot à l'échelle x-y
# ---------------------------------------------------
fig, ax = plt.subplots(figsize=(8, 8 * Ly / Lx))

im = ax.imshow(
    P,
    extent=[0, Lx, 0, Ly],
    origin='lower',
    aspect='equal'   # même échelle en x et y
)

ax.set_xlabel("x")
ax.set_ylabel("y")
ax.set_title("Champ de pression final (sortie Fortran)")

cb = fig.colorbar(im, ax=ax)
cb.set_label("p(x,y)")

plt.tight_layout()
plt.show()
