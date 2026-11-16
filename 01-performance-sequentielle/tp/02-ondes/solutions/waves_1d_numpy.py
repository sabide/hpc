# waves_1d_numpy.py : version vectorisée (sans boucle Python sur l'espace) de waves_1d.py.
# Usage : python3 waves_1d_numpy.py [N]
import sys
import time

import numpy as np

c = 1.0
L = 1.0
T = 1.0

N = int(sys.argv[1]) if len(sys.argv) > 1 else 1001
if N < 3:
    sys.exit("Usage : python3 waves_1d_numpy.py [N]   (N >= 3, 1001 par défaut)")

dx = L / (N - 1)
beta = 0.9
dt = beta * dx / c
nt = int(T / dt + 0.5)
beta2 = (c * dt / dx) ** 2

x = np.linspace(0.0, L, N)
p_prev = np.exp(-((x - 0.5 * L) ** 2) / (2.0 * 0.05 ** 2))
p = np.empty(N)
p_next = np.empty(N)

# p^1 (ordre 2)
p[0] = p_prev[0] + 0.5 * beta2 * (2.0 * p_prev[1] - 2.0 * p_prev[0])
p[-1] = p_prev[-1] + 0.5 * beta2 * (2.0 * p_prev[-2] - 2.0 * p_prev[-1])
p[1:-1] = p_prev[1:-1] + 0.5 * beta2 * (p_prev[:-2] - 2.0 * p_prev[1:-1] + p_prev[2:])

a = 2.0 * (1.0 - beta2)
start = time.perf_counter()
for n in range(nt):
    # Une seule expression sur des tranches : la boucle sur i est faite en C par NumPy
    p_next[1:-1] = -p_prev[1:-1] + a * p[1:-1] + beta2 * (p[:-2] + p[2:])
    p_next[0] = -p_prev[0] + a * p[0] + 2.0 * beta2 * p[1]
    p_next[-1] = -p_prev[-1] + a * p[-1] + 2.0 * beta2 * p[-2]
    p_prev, p, p_next = p, p_next, p_prev
elapsed = time.perf_counter() - start

print(f"N={N} nt={nt} temps={elapsed:.6f} s p(L/2)={p[N // 2]:.6f}")
