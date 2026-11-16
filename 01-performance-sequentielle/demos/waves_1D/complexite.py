import numpy as np
import time
import matplotlib.pyplot as plt

Number_points=[1001,2001,3001,4001,8001]

# Paramètres physiques
c = 1.0          # célérité
L = 1.0          # longueur du domaine
T = 1.0          # temps final
time_nb_points=[]
for n in Number_points:

    # Discrétisation
    N = n         # nombre de points (N > 1)
    dx = L / (N - 1)
    beta = 0.9       # nombre de Courant (beta = c dt / dx < 1)
    dt = beta * dx / c
    nt = int(T / dt)
    
    x = np.linspace(0.0, L, N)
    
    # Allocation
    p_prev = np.zeros(N)   # p^{n-1}
    p = np.zeros(N)        # p^{n}
    p_next = np.zeros(N)   # p^{n+1}
    
    # Condition initiale : bosse gaussienne au centre, vitesse initiale nulle
    x0 = 0.5 * L
    sigma = 0.05
    p_prev[:] = np.exp(-((x - x0) ** 2) / (2.0 * sigma ** 2))  # p(x,0)
    # vitesse initiale p_t(x,0) = 0 -> utilisé pour construire p^1 ci-dessous
    
    # Construction de p^1 (ordre 2 en temps, Taylor)
    # p^1 = p^0 + dt * v0 + 0.5 * dt^2 * c^2 * p_xx(x,0)
    # ici v0 = 0
    p[:] = p_prev.copy()
    
    # Laplacien discret pour n = 0
    beta2 = (c * dt / dx) ** 2
    
    # Bord gauche (Neumann p_x=0 => p_{-1} = p_1)
    p[0] = p_prev[0] + 0.5 * beta2 * (2.0 * p_prev[1] - 2.0 * p_prev[0])
    # Bord droit (Neumann p_x=0 => p_{N} = p_{N-2})
    p[-1] = p_prev[-1] + 0.5 * beta2 * (2.0 * p_prev[-2] - 2.0 * p_prev[-1])
    # Intérieur
    for i in range(1, N - 1):
        lap = p_prev[i - 1] - 2.0 * p_prev[i] + p_prev[i + 1]
        p[i] = p_prev[i] + 0.5 * beta2 * lap
    
    # Boucle en temps
    start = time.time()
    for n in range(1, nt):
        # Intérieur : schéma saute-mouton
        for i in range(1, N - 1):
            p_next[i] = (
                -p_prev[i]
                + 2.0 * (1.0 - beta2) * p[i]
                + beta2 * (p[i - 1] + p[i + 1])
            )
    
        # Bords Neumann (r=1 -> réflexion parfaite)
        # i = 0 : p_{-1}^n = p_1^n
        p_next[0] = (
            -p_prev[0]
            + 2.0 * (1.0 - beta2) * p[0]
            + 2.0 * beta2 * p[1]
        )
    
        # i = N-1 : p_{N}^n = p_{N-2}^n
        p_next[-1] = (
            -p_prev[-1]
            + 2.0 * (1.0 - beta2) * p[-1]
            + 2.0 * beta2 * p[-2]
        )
    
        # Rotation des niveaux de temps
        p_prev, p, p_next = p, p_next, p_prev
    
    end = time.time()
    time_nb_points.append(end-start)
    print(f"Simulation terminée en {end - start:.3f} s, nt={nt}, N={N}")
    # p contient p(x, T)
plt.figure()
plt.plot(Number_points, time_nb_points, marker='o', label="Execution time")
plt.xlabel("Number of spatial points N")
plt.ylabel("Execution time (s)")
plt.title("Execution time vs number of points for the 1D wave equation solver")
plt.grid(True)
plt.legend()
Plt.show() 
