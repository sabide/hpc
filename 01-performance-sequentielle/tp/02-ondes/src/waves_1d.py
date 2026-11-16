# waves_1d.py : équation d'onde 1D, schéma saute-mouton, bords de Neumann.
# Usage : python3 waves_1d.py [N]     (N >= 3 points, 1001 par défaut)
# Sortie : une ligne  N=... nt=... temps=... s p(L/2)=...
import sys
import time

import numpy as np

c = 1.0          # célérité
L = 1.0          # longueur du domaine
T = 1.0          # temps final

N = int(sys.argv[1]) if len(sys.argv) > 1 else 1001
if N < 3:
    sys.exit("Usage : python3 waves_1d.py [N]   (N >= 3, 1001 par défaut)")

dx = L / (N - 1)
beta = 0.9       # nombre de Courant : c*dt/dx < 1
dt = beta * dx / c
nt = int(T / dt + 0.5)
beta2 = (c * dt / dx) ** 2

x = np.linspace(0.0, L, N)
p_prev = np.zeros(N)   # p^{n-1}
p = np.zeros(N)        # p^{n}
p_next = np.zeros(N)   # p^{n+1}

# Condition initiale : bosse gaussienne, vitesse initiale nulle
x0 = 0.5 * L
sigma = 0.05
p_prev[:] = np.exp(-((x - x0) ** 2) / (2.0 * sigma ** 2))

# Construction de p^1 (ordre 2)
p[0] = p_prev[0] + 0.5 * beta2 * (2.0 * p_prev[1] - 2.0 * p_prev[0])
p[-1] = p_prev[-1] + 0.5 * beta2 * (2.0 * p_prev[-2] - 2.0 * p_prev[-1])
for i in range(1, N - 1):
    lap = p_prev[i - 1] - 2.0 * p_prev[i] + p_prev[i + 1]
    p[i] = p_prev[i] + 0.5 * beta2 * lap

start = time.perf_counter()
for n in range(nt):
    for i in range(1, N - 1):
        p_next[i] = (
            -p_prev[i]
            + 2.0 * (1.0 - beta2) * p[i]
            + beta2 * (p[i - 1] + p[i + 1])
        )
    # Bords de Neumann
    p_next[0] = -p_prev[0] + 2.0 * (1.0 - beta2) * p[0] + 2.0 * beta2 * p[1]
    p_next[-1] = -p_prev[-1] + 2.0 * (1.0 - beta2) * p[-1] + 2.0 * beta2 * p[-2]

    # Rotation des niveaux de temps
    p_prev, p, p_next = p, p_next, p_prev
elapsed = time.perf_counter() - start

print(f"N={N} nt={nt} temps={elapsed:.6f} s p(L/2)={p[N // 2]:.6f}")
