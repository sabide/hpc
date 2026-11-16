# HPC — Calcul haute performance (saison 2026-2027)

Dépôt **privé** : cours, démos, TP, corrigés et projet.
Les saisons précédentes sont accessibles par tags : `git checkout 2024-2025`, `git checkout 2025-2026`.

## Organisation

Un dossier par **module** (stable d'une année à l'autre). Le calendrier est dans [`planning.md`](planning.md).

```
00-environnement/              Azzurra, VPN, modules, Slurm, CMake, HDF5
01-performance-sequentielle/   layout mémoire, cache, tiling, roofline, ondes 1D/2D
02-mpi/                        communications point à point et collectives
projet/                        sujet, code de départ, dépendances
```

Chaque module suit la même structure :

```
NN-module/
├── cours/            slides (sources + PDF)
├── demos/            code montré en cours
└── tp/
    └── NN-nom/
        ├── enonce.md
        ├── CMakeLists.txt
        ├── src/          code distribué aux étudiants
        └── solutions/    corrigé (dépôt privé uniquement)
```

## Conventions

- Préfixe numérique = ordre pédagogique ; pas de date dans les noms de dossiers.
- Pas de binaire généré ni d'archive volumineuse dans git (voir `.gitignore`).
- Les corrigés ne sortent jamais de ce dépôt : si une version étudiante est publiée, l'exporter sans `solutions/`.
