import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation

# -----------------------
# Paramètres physiques
# -----------------------
A = 1.0          # amplitude
c = 1.0          # vitesse de propagation
f = 0.2          # fréquence (Hz)
omega = 2 * np.pi * f
k = omega / c    # nombre d'onde (omega = c k)

# Angle de propagation (en radians)
theta = np.pi / 2.0  # 30 degrés
kx = k * np.cos(theta)
ky = k * np.sin(theta)

# -----------------------
# Domaine spatial
# -----------------------
Lx, Ly = 10.0, 10.0
nx, ny = 201, 201
x = np.linspace(0, Lx, nx)
y = np.linspace(0, Ly, ny)
X, Y = np.meshgrid(x, y)

dx = x[1] - x[0]
dy = y[1] - y[0]

# -----------------------
# Temps (CFL pour stabilité)
# -----------------------
CFL = 0.5  # facteur de sécurité
dt = CFL * min(dx, dy) / (c * np.sqrt(2))
t_max = 40.0
n_frames = int(t_max / dt)

# -----------------------
# Conditions aux limites
# -----------------------
# r_bord = 1.0 -> bords parfaitement réfléchissants (Neumann)
# r_bord < 1.0 -> bords partiellement absorbants (amortissement)
r_bord = 0.0

# -----------------------
# Initialisation
# -----------------------
# Onde plane monochromatique au temps t=0
phi0 = kx * X + ky * Y
p_n = A * np.cos(phi0)           # p(x,y, t=0)
p_nm1 = A * np.cos(phi0 + omega * dt)  # p(x,y, t=-dt) pour lancer la propagation

p_np1 = np.zeros_like(p_n)

# -----------------------
# Préparation de la figure
# -----------------------
fig, ax = plt.subplots()
im = ax.imshow(p_n, extent=[0, Lx, 0, Ly], origin='lower',
               animated=True)
ax.set_xlabel("x")
ax.set_ylabel("y")
ax.set_title("Propagation d'une onde 2D avec 4 bords")
cb = fig.colorbar(im, ax=ax)
cb.set_label("p(x,y,t)")

time_text = ax.text(0.02, 0.95, '', transform=ax.transAxes, color='w')

# -----------------------
# Fonctions de mise à jour
# -----------------------
def apply_boundary_conditions(p):
    """
    Conditions aux limites sur les 4 bords.
    Ici : Neumann (réflexion) + éventuellement amortissement r_bord.
    """
    # Bords verticaux (x = 0 et x = Lx)
    p[:, 0]  = r_bord * p[:, 1]      # gauche
    p[:, -1] = r_bord * p[:, -2]     # droite

    # Bords horizontaux (y = 0 et y = Ly)
    p[0, :]  = r_bord * p[1, :]      # bas
    p[-1, :] = r_bord * p[-2, :]     # haut

def init():
    im.set_array(p_n)
    time_text.set_text('')
    return im, time_text

def animate(frame):
    global p_n, p_nm1, p_np1

    # Laplacien discret au temps n (point intérieur uniquement)
    lap = (
        (p_n[2:, 1:-1] - 2 * p_n[1:-1, 1:-1] + p_n[0:-2, 1:-1]) / dx**2 +
        (p_n[1:-1, 2:] - 2 * p_n[1:-1, 1:-1] + p_n[1:-1, 0:-2]) / dy**2
    )

    # Schéma saute-mouton (2D)
    p_np1[1:-1, 1:-1] = (
        2 * p_n[1:-1, 1:-1]
        - p_nm1[1:-1, 1:-1]
        + (c**2) * (dt**2) * lap
    )

    # Appliquer les conditions aux limites sur les 4 bords
    apply_boundary_conditions(p_np1)

    # Mise à jour des champs en temps
    p_nm1, p_n = p_n, p_np1.copy()

    # Mise à jour de l'affichage
    t = frame * dt
    im.set_array(p_n)
    time_text.set_text(f"t = {t:.2f} s")
    return im, time_text

ani = FuncAnimation(fig, animate, frames=n_frames,
                    init_func=init, blit=True, interval=30)

plt.show()
