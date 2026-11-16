import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation

# Paramètres physiques
A = 1.0         # amplitude
c = 1.0         # vitesse de propagation
f = 0.5         # fréquence (Hz)
omega = 2 * np.pi * f
k = omega / c   # nombre d'onde (car omega = c * k)

# Domaine spatial
L = 10.0
nx = 400
x = np.linspace(0, L, nx)

# Temps
dt = 0.02
t_max = 10

# Création de la figure
fig, ax = plt.subplots()
line, = ax.plot([], [], lw=2)
ax.set_xlim(0, L)
ax.set_ylim(-1.2 * A, 1.2 * A)
ax.set_xlabel("x")
ax.set_ylabel("p(x,t)")
ax.set_title("Onde monochromatique : p(x,t) = A cos(kx - ωt)")

time_text = ax.text(0.02, 0.9, '', transform=ax.transAxes)

def init():
    line.set_data([], [])
    time_text.set_text('')
    return line, time_text

def animate(frame):
    t = frame * dt
    p = A * np.cos(k * x - omega * t)
    line.set_data(x, p)
    time_text.set_text(f"t = {t:.2f} s")
    return line, time_text

n_frames = int(t_max / dt)
ani = FuncAnimation(fig, animate, frames=n_frames,
                    init_func=init, blit=True, interval=20)

plt.show()
