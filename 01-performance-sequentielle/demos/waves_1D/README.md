# Démo : équation d'onde 1D

Équation $p_{tt} = c^2 p_{xx}$ sur $[0, L]$, schéma saute-mouton d'ordre 2, bords de Neumann
(réflexion parfaite), condition initiale gaussienne, vitesse initiale nulle. Le même algorithme est écrit
en quatre langages.

| Fichier | Langage | Compiler / lancer |
|---|---|---|
| `waves_1d.c` | C | `gcc -O3 waves_1d.c -o waves_c -lm && ./waves_c` |
| `waves_1d.cpp` | C++ | `g++ -std=c++17 -O3 waves_1d.cpp -o waves_cpp && ./waves_cpp` |
| `waves_1d.f90` | Fortran | `gfortran -O3 waves_1d.f90 -o waves_f && ./waves_f` |
| `waves_1d.py` | Python / NumPy | `python3 waves_1d.py` |
| `complexite.py` | Python | `python3 complexite.py` : temps d'exécution pour $N = 1001 \dots 8001$ (nécessite `matplotlib`) |

Les trois codes compilés affichent le temps de calcul et la valeur $p(L/2, T) \approx 0{,}999875$.
**Vérifiez que vos trois sorties coïncident** : c'est un bon test de non-régression.

## Ce qu'on en tire

- **Complexité.** Le pas de temps vaut $\Delta t = \beta\,\Delta x / c$, donc le nombre de pas $n_t \propto N$ :
  le travail total croît comme $O(N^2)$. `complexite.py` le montre.
- **Performance.** Chaque point demande environ 5 opérations et 3 accès mémoire (lecture de $p$ et
  $p_{\text{prev}}$, écriture de $p_{\text{next}}$). Soit une intensité arithmétique idéale
  $I = 5/24 \approx 0{,}21$ flop/octet : très faible, donc un noyau **limité par la mémoire**, plus encore
  que le noyau `stencil` du TP (`../../tp/01-roofline`, $I = 5/16$), qui n'a qu'un tableau d'entrée.
- **Indexation.** C, C++ et Python indexent depuis 0 ; Fortran depuis 1. Le point central
  est `p[N/2]` en C et `p((N+1)/2)` en Fortran (pour $N$ impair).

## Pour aller plus loin

- Mesurer le noyau avec le roofline du TP et y placer l'équation d'onde.
- Comparer les compilateurs et les options (`-O0` à `-O3 -march=native`) sur `waves_1d.c`.
- Version 2D : `../fortran-2d`.
