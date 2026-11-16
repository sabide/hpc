# Planning 2026-2027

Mapping séance → module. À mettre à jour chaque année sans toucher à l'arborescence.

| Séance | Module | Contenu | Statut |
|--------|--------|---------|--------|
| S1 – cours 1 | `00-environnement` | Connexion à Azzurra, chaîne de compilation (modules, compilateurs, MPI, bibliothèques), Slurm avec CMake (jobs, compilation sur nœud de calcul, batch vs interactif) | à relire |
| S1 – cours 2 | `01-performance-sequentielle` | Équation d'onde 1D/2D, layout mémoire des tableaux, localité et cache, impact sur les boucles | à relire |
| S2 | `01-performance-sequentielle` | Tiling, roofline | à relire |
| S3–S5 | `02-mpi` | Point à point, collectives, TP ping-pong / halo 1D / quadrature / slabs | TP 03 et 04 à écrire |
| – | `projet` | Dérivées distribuées (decomp2d), gradient conjugué, communications P2P | sujet à mettre à jour (titre 2024/2025, chemins `/home/sabide`) |

## À faire pour 2026-2027

- [ ] Mettre à jour le sujet du projet (année, chemins, versions de modules Azzurra)
- [ ] Écrire les énoncés de `02-mpi/tp/03-quadrature` et `04-slab_decomposition` (fichiers vides)
- [ ] Ajouter le module mpi4py (supprimé du dépôt dans `321abd2`, récupérable avec `git show 7e12c5a:week-03_05/`)
- [ ] Ajouter `solutions/` pour chaque TP
