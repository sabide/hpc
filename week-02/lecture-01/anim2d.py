import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation

# -----------------------
# Paramètres physiques
# -----------------------
A = 1.0          # amplitude
c = 1.0          # vitesse de propagation
f = 0.5          # fréquence (Hz)
omega = 2 * np.pi * f
k = omega / c    # nombre d'onde (omega = c * k)

# Angle de propagation (en radians)
theta = np.pi / 2   # 30 degrés
kx = k * np.cos(theta)
ky = k * np.sin(theta)

# -----------------------
# Domaine spatial
# -----------------------
Lx, Ly = 10.0, 10.0
nx, ny = 200, 200
x = np.linspace(0, Lx, nx)
y = np.linspace(0, Ly, ny)
X, Y = np.meshgrid(x, y)

# -----------------------
# Temps
# -----------------------
dt = 0.03
t_max = 10
n_frames = int(t_max / dt)

# -----------------------
# Figure et animation
# -----------------------
fig, ax = plt.subplots()
p0 = A * np.cos(kx * X + ky * Y)  # champ initial
im = ax.imshow(p0, extent=[0, Lx, 0, Ly],
               origin='lower', animated=True)
ax.set_xlabel("x")
ax.set_ylabel("y")
ax.set_title("Onde plane monochromatique en 2D")

cb = fig.colorbar(im, ax=ax)
cb.set_label("p(x,y,t)")

time_text = ax.text(0.02, 0.95, '', transform=ax.transAxes, color='w')

def init():
    im.set_array(p0)
    time_text.set_text('')
    return im, time_text

def animate(frame):
    t = frame * dt
    p = A * np.cos(kx * X + ky * Y - omega * t)
    im.set_array(p)
    time_text.set_text(f"t = {t:.2f} s")
    return im, time_text

ani = FuncAnimation(fig, animate, frames=n_frames,
                    init_func=init, blit=True, interval=30)

plt.show()
