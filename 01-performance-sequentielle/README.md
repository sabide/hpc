# 01 — Performance séquentielle

Comprendre ce qui limite la vitesse d'un code **sur un seul cœur** : puissance crête, organisation de
la mémoire (ordre des boucles, caches), options de compilation, modèle roofline. Fil rouge : l'équation
d'onde 1D/2D.

## Contenu

```
cours/    slides (sources + PDF)
demos/    code montré en cours
tp/       TP (énoncé, code de départ, solutions/ réservé au dépôt privé)
```

| Séance | Contenu | Supports |
|---|---|---|
| S1 – cours 2 | équation d'onde 1D/2D, layout mémoire, localité et cache, impact sur les boucles | `cours/loop_optimize.pdf`, `demos/waves_1D`, `demos/fortran-2d`, `demos/anim*.py` |
| S1 – TD/TP (2 h) | complexité, mémoire, stockage 2D, langages, options de compilation, ordre des boucles, deux optimisations | `tp/02-ondes` |
| S2 (1 h) | puissance crête, ordre des boucles, options de compilation, roofline | `cours/puissance-crete-roofline` (`.tex`, `.pdf`), `tp/01-roofline` |
| S2 (suite) | tiling | `demos/tiling-1` |

## Démos

| Dossier | Contenu | Compiler / lancer |
|---|---|---|
| `demos/waves_1D` | équation d'onde 1D, schéma saute-mouton, bords de Neumann, en C, C++, Fortran, Python ; `complexite.py` trace le temps en fonction de N | voir `demos/waves_1D/README.md` |
| `demos/fortran-2d` | équation d'onde 2D en Fortran, écrit `p_final.dat` ; `plot.py` le trace | `gfortran -O3 tube_2d_ondes.F90 -o tube_2d && ./tube_2d && python3 plot.py` |
| `demos/anim1d.py`, `anim2d.py`, `anim2d_bords.py` | animations de l'équation d'onde (matplotlib) | `python3 anim1d.py` |
| `demos/tiling-1` | produit matrice-matrice : ordres de boucles, roofline, tiling | voir `demos/tiling-1/README.md` |

## TP

- [`tp/02-ondes`](tp/02-ondes/enonce.md) : TD sur papier puis TP de 2 h sur l'équation d'onde (complexité,
  comparaison C/Fortran/Python/NumPy, options de compilation, ordre des boucles, optimisations à la main).
  À faire **avant** le TP roofline.
- [`tp/01-roofline`](tp/01-roofline/enonce.md) : quatre exercices de prise en main en 1 h (crête, boucles,
  options de compilation, roofline). Un programme unique (`src/kernels.cpp`) sert à tous les exercices.
  L'exercice 2 (ordre des boucles) reprend en plus court ce que fait `tp/02-ondes` : le raccourcir ou le
  traiter comme une révision si les deux TP sont faits.

## Liens entre les supports

- Le **TP roofline** donne l'outil de lecture : calculer l'intensité arithmétique d'un noyau avant de
  l'optimiser. La **démo tiling** en est la suite : réutiliser les données depuis le cache pour monter
  dans le roofline.
- Les codes d'**ondes** sont des noyaux limités par la mémoire (intensité arithmétique faible) : ils
  illustrent pourquoi l'on s'intéresse à la localité, puis à MPI (module `02-mpi`).

## Où exécuter

Compilations rapides sur le nœud de connexion de **Zen** ; **mesures de performance sur un nœud de calcul**
(`sbatch`, de préférence `--exclusive`) : un nœud de connexion est partagé et bruite les mesures. Voir
`00-environnement` (connexion à Zen, Slurm).

## Dépendances

`g++`/`gcc`, `gfortran`, `cmake` (≥ 3.16), Python 3 avec `numpy` et `matplotlib` pour les tracés
(`module load python` ou `pip install --user numpy matplotlib`).
