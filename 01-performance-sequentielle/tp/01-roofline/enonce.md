# TP 01 — Puissance crête, boucles, options de compilation, roofline (1 h)

Objectif : se familiariser, avec des mesures simples, avec quatre notions du cours.

| Exercice | Notion | Durée |
|---|---|---|
| 0 | Prise en main : compiler et lancer le programme de mesure | 5 min |
| 1 | **Puissance crête** d'un cœur : calcul théorique et mesure | 10 min |
| 2 | **Ordre des boucles** et accès mémoire | 10 min |
| 3 | **Options de compilation** et vectorisation | 15 min |
| 4 | **Roofline** : intensité arithmétique et diagramme | 15 min |
| — | Bilan | 5 min |

Un seul programme, `src/kernels.cpp`, sert aux quatre exercices. Il mesure des noyaux de calcul
très courts (quelques lignes chacun) et affiche, pour chacun, le temps, le débit de calcul
(GFLOP/s), le débit mémoire (GB/s) et l'intensité arithmétique (flop/octet).

## Avant de commencer

**Où exécuter ?** Sur un **nœud de calcul**, pas sur le nœud de connexion : celui-ci est partagé,
les mesures y sont bruitées. Utilisez un job interactif ou `sbatch` (voir la partie Slurm).
Un script de départ, **à adapter** (la partition se trouve avec `sinfo`) :

```bash
#!/bin/bash
#SBATCH --job-name=roofline
#SBATCH --partition=<partition>
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --exclusive
#SBATCH --time=00:10:00
#SBATCH --output=roofline_%j.out

./sweep.sh ./kernels > resultats.txt
```

**Mesurer proprement.** Répétez une mesure suspecte, comparez-la à ses voisines, et gardez en tête
que tout autre travail sur la machine la perturbe. Notez le nom du processeur (`lscpu`).

## Exercice 0 — Prise en main (5 min)

```bash
cd src
g++ -std=gnu++17 -O3 -march=native kernels.cpp -o kernels
./kernels all
```

Les noyaux sont : `fma_peak` (calcul pur), `vadd` ($c_i = a_i + b_i$), `axpy` ($y_i = a x_i + y_i$),
`dot` (produit scalaire), `stencil` (schéma à 3 points, comme l'équation d'onde 1D) et `matmul`
(produit matrice-matrice).

**Q0.** Pour chaque noyau, relevez le débit de calcul (GFLOP/s) et le débit mémoire (GB/s).
Lequel est le plus rapide en GFLOP/s ? Lequel déplace le plus d'octets par seconde ?

> Pourquoi `-std=gnu++17` et non `-std=c++17` ? Avec GCC, le mode `c++17` strict interdit de
> fusionner `a*b+c` en une instruction FMA : la mesure de la crête serait fausse.

## Exercice 1 — Puissance crête (10 min)

La puissance crête d'un cœur est

$$P_{\text{crête}} = f \times n_{\text{FMA}} \times w \times 2$$

avec $f$ la fréquence, $n_{\text{FMA}}$ le nombre d'unités FMA par cœur, $w$ le nombre de doubles par
registre vectoriel, et le facteur 2 pour les deux opérations (multiplication et addition) d'un FMA.

1. Avec `lscpu`, relevez le modèle, la fréquence et les jeux d'instructions vectorielles
   (`avx2`, `avx512f` sur x86 ; `neon`/`asimd` sur ARM).
   Largeur d'un registre : AVX2 = 256 bits = 4 doubles, AVX-512 = 512 bits = 8 doubles,
   NEON = 128 bits = 2 doubles.
2. Cherchez dans la documentation du fabricant le nombre d'unités FMA par cœur
   (il vaut souvent 2 ; à vérifier pour votre modèle). **Calculez $P_{\text{crête}}$ pour un cœur.**
3. Mesurez : `./kernels fma_peak`. Comparez au calcul théorique.
4. Recompilez **sans** `-march=native` et relancez. Que se passe-t-il ?
5. Si votre processeur a AVX-512, recompilez avec `-DVW=8` et `-march=native`. Et si le résultat
   ne change pas ?

**Q1.** Quel pourcentage de la crête théorique obtenez-vous ? Donnez deux raisons possibles de
l'écart. Combien vaudrait la crête d'un nœud entier (tous les cœurs, tous les sockets) ?

## Exercice 2 — Ordre des boucles (10 min)

Deux noyaux font la même chose, $B = 2A$ sur une matrice $n \times n$ stockée **ligne par ligne**,
mais parcourent les indices dans un ordre différent :

```cpp
// scale_rows : i extérieur, j intérieur      // scale_cols : j extérieur, i intérieur
for i: for j: B[i*n+j] = 2*A[i*n+j];          for j: for i: B[i*n+j] = 2*A[i*n+j];
```

1. Lancez `./kernels scale_rows` puis `./kernels scale_cols` (n = 4096 par défaut).
2. Faites varier la taille :

   ```bash
   for n in 128 256 512 1024 2048 4096; do ./kernels scale_rows $n; ./kernels scale_cols $n; done | grep -v '^#'
   ```

3. Refaites les mesures avec des tailles **voisines** des puissances de 2 :

   ```bash
   for n in 128 129 1024 1025 4096 4097; do ./kernels scale_rows $n; ./kernels scale_cols $n; done | grep -v '^#'
   ```

**Q2.** Quel est le rapport de débit entre les deux versions pour n = 4096 ? Une ligne de cache
fait 64 octets : combien de doubles sont utilisés par ligne chargée dans `scale_cols` ?
Quand la matrice tient dans le cache (n = 128), `scale_cols` reste lent : pourquoi l'écart est-il
quand même grand ?

**Q2 bis.** Que se passe-t-il entre n = 128 et n = 129, entre 4096 et 4097 ? Dans `scale_cols`,
deux éléments consécutifs d'une colonne sont séparés de $8n$ octets : que se passe-t-il quand
$8n$ est une puissance de 2 (associativité du cache) ? Quelle consigne pratique en déduisez-vous
pour la taille des tableaux ?

**Q2 ter.** Un tableau Fortran est stocké **colonne par colonne**. Quel doit être l'ordre des
boucles pour un parcours efficace ?

## Exercice 3 — Options de compilation (15 min)

Compilez le même code avec six jeux d'options :

```bash
for f in "-O0" "-O1" "-O2" "-O3" "-O3 -march=native" "-O3 -march=native -ffast-math"; do
    name=$(echo "$f" | tr -d ' =-')
    g++ -std=gnu++17 $f kernels.cpp -o kernels_$name
done
```

Pour chaque exécutable, relevez le débit (GFLOP/s) de `fma_peak`, `axpy`, `dot` et `stencil`
(`./kernels_XXX dot 10000000`, etc.) et remplissez :

| options | fma_peak | axpy | dot | stencil |
|---|---|---|---|---|
| `-O0` | | | | |
| `-O1` | | | | |
| `-O2` | | | | |
| `-O3` | | | | |
| `-O3 -march=native` | | | | |
| `-O3 -march=native -ffast-math` | | | | |

**Rapport de vectorisation.** Demandez au compilateur ce qu'il a fait de la boucle de `dot` :

```bash
L=$(grep -n 's += x\[i\] \* y\[i\]' kernels.cpp | cut -d: -f1); echo "boucle de dot : ligne $L"
# GCC
g++ -std=gnu++17 -O3 -march=native -fopt-info-vec-optimized -fopt-info-vec-missed -c kernels.cpp -o /dev/null 2>&1 | grep "kernels.cpp:$L:"
# Clang
clang++ -std=gnu++17 -O3 -march=native -Rpass=loop-vectorize -Rpass-missed=loop-vectorize -c kernels.cpp -o /dev/null 2>&1 | grep "kernels.cpp:$L:"
```

Refaites la même commande avec `-ffast-math` et comparez les messages.

**Q3.** (a) Quelle option fait gagner le plus, et sur quel noyau ?
(b) Le noyau `dot` ne gagne presque rien en `-O3`. Que dit le rapport de vectorisation pour la boucle
de `k_dot` (GCC : « couldn't vectorize » ; Clang : la boucle est « vectorisée » mais la somme reste
ordonnée) ? Pourquoi l'option `-ffast-math` change-t-elle la réponse ?
(c) **Pour un mathématicien appliqué** : l'addition flottante est-elle associative ? Que change
`-ffast-math` au résultat de `dot` ? Donnez un exemple où ce changement peut être gênant.
(d) Peut-on toujours utiliser `-O3 -ffast-math` ?

## Exercice 4 — Roofline (15 min)

Le modèle roofline borne la performance d'un noyau d'intensité arithmétique $I$ (flop par octet
transféré) par

$$P \le \min\bigl(P_{\text{crête}},\ \beta \, I\bigr)$$

où $\beta$ est la bande passante mémoire. Le **point de rupture** est $I^* = P_{\text{crête}} / \beta$ :
en dessous, le noyau est limité par la mémoire ; au dessus, par le calcul.

**Avant de mesurer, par le calcul.** Complétez l'intensité de chaque noyau (en flop/octet, un
double = 8 octets, chaque donnée lue ou écrite une fois) :

| noyau | flops par élément | octets par élément | $I$ |
|---|---|---|---|
| `vadd` ($c_i = a_i + b_i$) | 1 | 24 (2 lectures, 1 écriture) | $1/24$ |
| `axpy` ($y_i = a x_i + y_i$) | 2 | | |
| `dot` ($s \mathrel{+}= x_i y_i$) | 2 | | |
| `stencil` ($u'_i = a u_{i-1} + b u_i + c u_{i+1}$) | 5 | 16 (u lu une fois, u' écrit une fois) | $5/16$ |
| `matmul` (n × n, idéal) | $2n^3$ au total | $24n^2$ au total | |

**Mesure.**

```bash
./sweep.sh ./kernels > resultats.txt       # environ 1 minute
python3 plot_roofline.py resultats.txt     # tableau et figure roofline.png
```

Si matplotlib n'est pas disponible (`module load python`, ou `pip install --user matplotlib`), le
tableau est affiché quand même.

**Q4.**
1. Quelle est votre crête $P_{\text{crête}}$, votre bande passante $\beta$ et votre $I^*$ ?
2. Pour chaque noyau, annoncez avant de lire le tableau s'il est limité par la **mémoire** ou
   par le **calcul**. Vérifiez.
3. Certains points sont **au-dessus** du toit mémoire (petites tailles). Pourquoi ?
4. `dot` est très en dessous du toit. Recompilez avec `-O3 -march=native -ffast-math`, relancez
   `./sweep.sh`, retracez. Qu'observez-vous ? (Lien avec l'exercice 3.)
5. `matmul` est du côté « calcul » mais n'atteint qu'une fraction de la crête. Que lui manque-t-il ?
   (Indice : comptez les accès mémoire que fait chaque FMA dans la boucle intérieure de `k_matmul` ; pistes dans `../../demos/tiling-1`.)
6. Où se situe le noyau `stencil` de l'équation d'onde ? Qu'en concluez-vous pour le solveur 1D/2D du cours ?

## Bilan (5 min)

Complétez de mémoire :

1. La crête d'un cœur dépend de la fréquence, du nombre d'unités ........., de la largeur ........ et du facteur ....... du FMA.
2. Un parcours de tableau est rapide quand on suit l'ordre du ........ en mémoire.
3. Sans `-O2`/`-O3`, on perd un facteur ..... ; sans `-march=native`, on perd ..... ; sans `-ffast-math`, une ........ ne se vectorise pas.
4. Un noyau d'intensité $I < I^*$ est limité par la .........., pas par la puissance de calcul.
5. Avant d'optimiser, on **mesure** et on se compare au ........ .

## Pour aller plus loin

- `../../demos/tiling-1` : produit matrice-matrice, ordres de boucles `ijk` / `ikj`, tiling.
- Vectoriser à la main `dot` avec plusieurs accumulateurs, sans `-ffast-math`.
- Mesurer la bande passante cœur par cœur avec OpenMP (séances suivantes).
- Mesurer la latence mémoire (parcours de liste chaînée) et tracer un roofline par niveau de cache.
