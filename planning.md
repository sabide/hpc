# Planning 2026-2027

Mapping séance → module. À mettre à jour chaque année sans toucher à l'arborescence.

| Séance | Module | Contenu | Statut |
|--------|--------|---------|--------|
| S1 – cours 1 | `00-environnement` | Panorama du HPC (`00-generalites-hpc`), création de compte et connexion à Zen (`01-connexion-zen`, `01-creation-compte-zen.qmd`), architecture d'un supercalculateur (`02-supercalculateur`) ; **à venir** : chaîne de compilation (modules, compilateurs, MPI, bibliothèques), Slurm avec CMake (jobs, compilation sur nœud de calcul, batch vs interactif) | supports écrits, à relire ; Slurm à écrire |
| S1 – cours 2 | `01-performance-sequentielle` | Équation d'onde 1D/2D, layout mémoire des tableaux, localité et cache, impact sur les boucles | à relire |
| S1 – TD/TP (2 h) | `01-performance-sequentielle` | `tp/02-ondes` : TD papier (complexité, mémoire, stockage 2D, intensité), TP complexité 1D/2D, langages, options de compilation, ordre des boucles, optimisations (corrigé dans `solutions/`) | écrit ; testé sur ARM, **à tester sur Zen (x86)** |
| S2 (1 h) | `01-performance-sequentielle` | Puissance crête, ordre des boucles, options de compilation, roofline : `cours/puissance-crete-roofline` + `tp/01-roofline` (4 exercices, corrigé dans `solutions/`) | écrit ; testé sur ARM, **à tester sur Zen (x86)** |
| S2 (suite) | `01-performance-sequentielle` | Tiling (démo `demos/tiling-1`) | à relire, pas de TP |
| S3–S5 | `02-mpi` | Point à point, collectives, TP ping-pong / halo 1D / quadrature / slabs | TP 03 et 04 à écrire |
| – | `projet` | Dérivées distribuées (decomp2d), gradient conjugué, communications P2P | sujet à mettre à jour (titre 2024/2025, chemins `/home/sabide`) |

## À faire pour 2026-2027

- [ ] Mettre à jour le sujet du projet (année, chemins, versions de modules Azzurra)
- [ ] Écrire les énoncés de `02-mpi/tp/03-quadrature` et `04-slab_decomposition` (fichiers vides)
- [ ] Ajouter le module mpi4py (supprimé du dépôt dans `321abd2`, récupérable avec `git show 7e12c5a:week-03_05/`)
- [ ] Ajouter `solutions/` pour chaque TP (fait pour `01-performance-sequentielle/tp/01-roofline`)
- [ ] Tester `tp/02-ondes` sur un nœud de Zen (x86) : `gfortran`, `gcc`, `python3`+`numpy`, durées des exécutions Python et 2D
- [ ] Tester `tp/01-roofline` sur un nœud de Zen (x86, AVX2/AVX-512) : valeurs par défaut `VW`/`NV` de `fma_peak`, script Slurm (`<partition>` à renseigner)
- [ ] Trancher Azzurra / Zen : `00-environnement/cours/how_to_use_azzurra.md`, `README.md` et le sujet du projet parlent encore d'Azzurra
- [ ] Publier les supports étudiants (PDF) dans `sabide/hpc-public` ; activer GitHub Pages pour les slides Quarto
- [ ] Vérifier les chiffres d'actualité de `00-generalites-hpc` (TOP500 de juin 2026) après la liste de novembre
