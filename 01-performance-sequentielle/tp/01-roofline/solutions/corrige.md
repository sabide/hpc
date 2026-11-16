# Corrigé — TP 01 roofline (enseignant, dépôt privé uniquement)

Les ordres de grandeur ci-dessous ont été mesurés sur un **Apple M3 Pro (ARM, 1 cœur)** avec
Clang 23 et g++ 13. Ce n'est **pas** la machine des étudiants : sur Zen (x86 ?) les valeurs
absolues seront différentes. Ce qui doit se retrouver, ce sont les **rapports** et les **raisonnements**.
Machine non réservée pendant mes mesures : variations de l'ordre de ±30 % d'une exécution à l'autre.

## Exercice 0

`fma_peak` donne le plus de GFLOP/s (calcul pur, tout en registres). `vadd`, `axpy`, `stencil` déplacent
le plus d'octets par seconde (dizaines de GB/s) mais très peu de flops par octet.
`dot` est lent en GFLOP/s alors qu'il lit peu de données : voir exercice 3.

## Exercice 1 — Puissance crête

Formule : $P = f \times n_{FMA} \times w \times 2$.

- Exemple x86 AVX2 à 2,5 GHz, 2 FMA, $w = 4$ : $2{,}5 \times 2 \times 4 \times 2 = 40$ GFLOP/s par cœur.
- Exemple AVX-512 à 2,5 GHz, 2 FMA, $w = 8$ : 80 GFLOP/s par cœur.
- Crête d'un nœud : multiplier par le nombre de cœurs (tous les sockets).

Mesure attendue : 70 à 95 % de la crête théorique. Raisons de l'écart : fréquence réellement tenue
différente de la fréquence nominale (turbo, ou baisse de fréquence avec AVX-512), nombre d'unités FMA
réellement disponibles (certains modèles n'en ont qu'une en 512 bits), pas assez de registres
indépendants pour masquer la latence du FMA.

- **Sans `-march=native`** (x86) : le compilateur ne produit que du SSE2 (128 bits, pas de FMA) ;
  la crête chute d'un facteur 2 à 4. Sur ARM, rien ne change : NEON et FMA sont de base.
- **AVX-512** : `-DVW=8 -march=native` doit doubler la mesure par rapport à `VW=4`.
  Si le résultat ne change pas : le processeur n'a qu'une unité FMA 512 bits, ou il baisse sa fréquence.
- Sur le M3 Pro : environ 27 à 30 GFLOP/s (Clang) ; 22 GFLOP/s (g++ 13).

## Exercice 2 — Ordre des boucles

Mesures (M3 Pro, `-O3`, débit en GB/s) :

| n | `scale_rows` | `scale_cols` | rapport |
|---|---|---|---|
| 128 | 147 | 4,4 | 33 |
| 512 | 78 | 2,7 | 30 |
| 1024 | 78 | 2,2 | 36 |
| 4096 | 68 | 1,4 | 50 |

Avec `g++` 13 sur le même noyau (`kernels.cpp`), j'ai mesuré un écart encore plus grand, de **190 à 320** selon le niveau d'optimisation :
le comportement dépend du compilateur, mais l'ordre de grandeur « plusieurs dizaines à plusieurs centaines » est robuste.
Pour une dimension égale à une puissance de 2, cet écart est **très variable d'une exécution à l'autre** (de 50 à 300 avec `loop_order.c`
du TP `02-ondes`, même compilateur) : donner une fourchette, et préférer une taille voisine (4097) pour une mesure stable.

- **Q2.** Rapport de l'ordre de 50 à n = 4096. Dans `scale_cols`, chaque ligne de cache chargée (64 octets,
  8 doubles) n'est utilisée que pour **1** double avant d'être évincée : on transfère 8 fois plus que nécessaire.
  À n = 128 la matrice tient dans le cache, mais `scale_cols` reste lent : le parcours en saut
  de $8n$ octets n'est pas vectorisable et déclenche des conflits dans le cache (voir Q2 bis).
- **Q2 bis.** n = 128 → 129 : le rapport passe de 29 à 2,5 ; 4096 → 4097 : de 86 à 25.
  Quand $8n$ est une puissance de 2, les éléments d'une colonne tombent tous dans les **mêmes ensembles**
  du cache (associativité limitée) et s'évincent mutuellement même si le cache est loin d'être plein
  (*conflict misses*). Consigne : **éviter les puissances de 2** comme dimension principale (ajouter un petit
  rembourrage, par exemple +8 ou +1), et surtout parcourir dans l'ordre mémoire.
- **Q2 ter.** Fortran stocke par colonnes : la boucle **intérieure** doit porter sur le **premier** indice
  (`do j ... do i ... a(i,j)`), à l'inverse du C.

## Exercice 3 — Options de compilation (Clang 23, M3 Pro, GFLOP/s, N = $10^7$)

| options | fma_peak | axpy | dot | stencil |
|---|---|---|---|---|
| `-O0` | 3,0 | 1,2 | 1,3 | 1,6 |
| `-O1` | 27 | 4,4 | 1,3 | 5,1 |
| `-O2` | 25 | 6,3 | 1,9 | 14 |
| `-O3` | 29 | 6,0 | 1,9 | 13 |
| `-O3 -march=native` | 27 | 6,2 | 1,9 | 14 |
| `-O3 -march=native -ffast-math` | 31 | 7,3 | **8,8** | 14 |

- **(a)** Le plus gros gain vient de `-O0` → `-O1`/`-O2` : facteur environ 9 sur `fma_peak`, 5 sur `axpy`
  et `stencil` (le code non optimisé recharge tout depuis la mémoire à chaque opération).
  `-march=native` compte sur x86 (FMA, vecteurs larges), beaucoup moins sur ARM.
- **(b)** `dot` est une **réduction** : $s \leftarrow s + x_i y_i$. Chaque addition dépend de la précédente
  (latence de l'addition flottante, environ 3 à 4 cycles), d'où environ 1,9 GFLOP/s quelle que soit
  la mémoire. GCC écrit « couldn't vectorize loop » ; Clang vectorise les multiplications mais garde la somme
  **ordonnée**, donc sans gain. Avec `-ffast-math`, le compilateur peut réordonner les additions,
  utiliser plusieurs sommes partielles indépendantes, et le noyau passe à environ 8,8 GFLOP/s
  (facteur 4,6), c'est-à-dire qu'il est cette fois limité par la bande passante.
- **(c)** Non : $(a+b)+c \ne a+(b+c)$ en arithmétique flottante (arrondis). `-ffast-math` change l'ordre de
  sommation, donc les derniers chiffres du résultat, et ils dépendent du nombre d'accumulateurs, donc de la
  machine et du compilateur. Gênant pour : la **reproductibilité** (résultats différents d'une machine à
  l'autre ou d'un nombre de processus MPI à l'autre), les tests de non-régression, les sommes à grandes
  dynamiques (une somme de $10^8$ termes de signes variés), les algorithmes compensés (Kahan) que
  `-ffast-math` peut **détruire**.
- **(d)** Non. `-ffast-math` suppose aussi l'absence de NaN/Inf et l'associativité : à réserver aux noyaux
  dont on a validé la sensibilité aux arrondis. Alternative sûre : écrire soi-même plusieurs accumulateurs.

## Exercice 4 — Roofline

Intensités (flop/octet) :

| noyau | $I$ |
|---|---|
| `vadd` | 1/24 ≈ 0,042 |
| `axpy` | 2/24 = 1/12 ≈ 0,083 |
| `dot` | 2/16 = 1/8 = 0,125 |
| `stencil` | 5/16 ≈ 0,31 |
| `matmul` (idéal) | $2n^3 / 24n^2 = n/12$ : 5,3 (n = 64) ; 21 (n = 256) ; 43 (n = 512) |

Valeurs sur le M3 Pro (un cœur) : crête ≈ 27 GFLOP/s, bande passante ≈ 88 GB/s,
$I^* \approx 0{,}30$ flop/octet.

1. $I^* = P_{crête} / \beta$.
2. `vadd`, `axpy`, `dot` : mémoire ($I < I^*$). `stencil` : $I = 0{,}31$ est **sur** le point de rupture.
   `matmul` : calcul ($I \gg I^*$).
3. Pour de petites tailles, les données tiennent dans les caches (L1, L2) dont la bande passante est
   bien supérieure à celle de la RAM : le toit « RAM » ne s'applique plus. Chaque niveau de cache a
   son propre toit.
4. `dot` est à environ 20 % de son toit : il n'est pas limité par la mémoire mais par la **latence**
   de la chaîne d'additions. Avec `-ffast-math` il remonte vers le toit (exercice 3).
   Morale : le roofline donne une **borne** ; être sous la borne signale un problème d'implémentation.
5. `matmul` en boucles `i,k,j` plafonne à 40-50 % de la crête, **même à n = 64** où tout tient dans le cache.
   Dans la boucle intérieure, chaque FMA fait **2 lectures** (`B[k][j]` et `C[i][j]`) et **1 écriture**
   (`C[i][j]`) : le goulot est le débit de chargement/stockage du cache L1, pas la RAM. Pour les grandes
   tailles s'ajoute le défaut de réutilisation : `B` est relue en entier pour chaque `i` et sort du cache.
   Remèdes : garder une partie de `C` **en registres** pendant plusieurs FMA, et **tiling** pour réutiliser
   `B` depuis le cache (séance suivante, `demos/tiling-1`). Le roofline donne l'intensité d'un algorithme
   **idéal** ; une implémentation naïve reste sous le toit.
6. Le schéma saute-mouton de `waves_1D` fait 5 flops par point et touche 3 tableaux (lecture de `p` et `p_prev`,
   écriture de `p_next`) : $I = 5/24 \approx 0{,}21$ flop/octet, **plus bas** que le `stencil` du TP
   ($5/16 \approx 0{,}31$, un seul tableau lu). Sur le M3 on est sous ou au voisinage de $I^*$ ; sur un cœur x86
   de serveur $I^*$ est en général plus grand, donc franchement sous le toit mémoire (à vérifier avec les
   mesures des étudiants). Le solveur
   est **limité par la mémoire** pour tout cœur supplémentaire (la bande passante est partagée entre
   cœurs). Augmenter le nombre de cœurs aide jusqu'à saturation de la bande passante, pas au-delà ; pour
   aller plus vite, il faut réduire le trafic (fusion de boucles, tiling temporel) ou ajouter des
   **nœuds** (MPI : la bande passante agrégée augmente).

## Bilan

1. unités FMA, largeur vectorielle, facteur **2**.
2. l'ordre du **stockage**.
3. facteur **~5 à 10** ; **~2 à 4** sur x86 ; une **réduction**.
4. **mémoire**.
5. **roofline** (la borne théorique).

## Notes pour l'enseignant

- **Bruit de mesure.** Sur machine partagée, un même noyau peut varier de ×2 d'une exécution à l'autre
  (constaté ici avec un navigateur ouvert). Faire lancer le TP par `sbatch --exclusive`.
- **Piège GCC.** `-std=c++17` (mode strict) désactive la contraction FMA : `fma_peak` est alors faux sur x86.
  Les commandes de l'énoncé utilisent `-std=gnu++17`.
- **Piège compilateur.** Un appel de fonction pure répété avec des arguments identiques est sorti de la boucle de
  mesure par l'optimiseur (temps nul). `kernels.cpp` s'en protège avec une valeur `volatile` (`seed`).
- **AVX-512.** `VW` vaut 4 par défaut en x86 : sur un processeur AVX-512 il faut `-DVW=8` pour voir la vraie
  crête. Si les accumulateurs sont trop nombreux, les registres débordent (mesuré : 13 puis 2,6 GFLOP/s au lieu de 27
  avec trop de registres) : ajuster `-DNV=`.
- **Non testé sur Zen.** Le code a été validé sur ARM (Clang, g++ 13). La compilation x86/AVX n'a pas été
  testée ; vérifier avant la séance sur un nœud de Zen.
