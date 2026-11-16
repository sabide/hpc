# TD/TP 02 — Équation d'onde : coût, mémoire, compilation, boucles (2 h)

Fil rouge : l'équation d'onde 1D et 2D (démos `../../demos/waves_1D` et `../../demos/fortran-2d`).
On apprend à **prédire** un temps de calcul, puis à le **mesurer** et à l'**améliorer** sur un seul cœur.

| Durée | Partie | Contenu |
|---|---|---|
| 10 min | Mise en route | compiler et lancer les codes 1D |
| 25 min | **TD sur papier** | complexité, mémoire, stockage 2D, intensité arithmétique |
| 30 min | **TP A** | complexité mesurée en 1D, comparaison des langages |
| 25 min | **TP B** | complexité 2D, options de compilation, ordre des boucles |
| 20 min | **TP C** | deux optimisations à la main |
| 10 min | Bilan | tableau récapitulatif |

**Règle de la séance : avant chaque mesure, notez ce que vous attendez.** Un écart avec la prédiction
est ce qui vous apprend quelque chose.

**Où exécuter ?** Sur un **nœud de calcul** de Zen (job interactif ou `sbatch`, voir la partie Slurm) :
le nœud de connexion est partagé et bruite les mesures. Prévoyez 1 cœur. Les durées inférieures à
environ 10 ms sont peu fiables : **répétez une mesure suspecte** et regardez la tendance plutôt qu'un point isolé.

## Contenu du dossier

```
src/
  waves_1d.c, waves_1d.f90, waves_1d.py   équation d'onde 1D : C, Fortran, Python (taille N en argument)
  tube_2d.F90                             équation d'onde 2D dans un tube (Fortran)
  loop_order.c                            B = 2A sur une matrice, deux ordres de boucles
  scaling.sh                              mesure le temps pour plusieurs tailles et estime l'exposant
  compare_fields.py                       écart maximal entre deux champs p_final.dat
CMakeLists.txt                            construction de tous les exécutables
```

Tous les programmes affichent une ligne de la forme `N=... nt=... temps=... s ...`.

## Mise en route (10 min)

```bash
cd src
gcc -O3 -o waves_c waves_1d.c -lm
gfortran -O3 -o waves_f waves_1d.f90
./waves_c 1001
./waves_f 1001
python3 waves_1d.py 1001
```

**Vérifiez que les trois programmes donnent la même valeur `p(L/2)`** (6 décimales). Si ce n'est pas le
cas, il y a un défaut dans l'un des codes, et inutile de comparer des temps avant de l'avoir réglé.

## TD sur papier (25 min)

On prend $c = L = T = 1$, $\beta = c\,\Delta t/\Delta x = 0{,}9$, $\Delta x = L/(N-1)$.

**TD 1 — Nombre de pas et complexité.**
1. Exprimez $\Delta t$ puis le nombre de pas $n_t = T/\Delta t$ en fonction de $N$. Montrez que $n_t \propto N$.
2. À chaque pas, on met à jour $N$ points. En déduire que le coût total est en $O(N^2)$.
   Si l'on double $N$, par quel facteur le temps est-il multiplié ?
3. En 2D, avec $N_x \times N_y$ points et $\Delta t \propto \min(\Delta x, \Delta y)$ : quelle complexité en fonction du
   nombre de points par unité de longueur `res` (le maillage a environ $10\,res \times res$ points) ?
   Par quel facteur le temps est-il multiplié quand `res` double ?

**TD 2 — Mémoire.**
1. En 1D, trois tableaux de $N$ doubles (`p_prev`, `p`, `p_next`) : quelle taille mémoire pour $N = 32001$ ?
2. En 2D, trois tableaux de $n_x \times n_y$ doubles. Calculez la taille pour `res = 50` ($501 \times 51$),
   puis pour `res = 200`. À partir de quelle valeur de `res` dépasse-t-on un cache de 32 Mio ?

**TD 3 — Stockage d'un tableau 2D.** Un tableau de $n$ lignes et $n$ colonnes est stocké en mémoire linéaire.
1. En C (ligne par ligne, indices depuis 0), quelle est l'adresse, en nombre de doubles, de $A[i][j]$ ?
2. En Fortran (colonne par colonne, indices depuis 1), quelle est l'adresse de `A(i,j)` ?
3. Dans une double boucle, quelle est la distance en octets entre deux accès consécutifs de la boucle intérieure
   si elle porte sur $j$ en C ? sur $i$ en C ?
4. Une ligne de cache fait 64 octets. Pour $n = 4096$, quelle fraction de chaque ligne de cache est utilisée par la
   boucle intérieure sur $i$ en C ?

**TD 4 — Intensité arithmétique du schéma.** Le noyau de la boucle en temps 1D est

$$p_i^{n+1} = -p_i^{n-1} + 2(1-\beta^2)\,p_i^{n} + \beta^2\,(p_{i-1}^{n} + p_{i+1}^{n}).$$

1. Combien de flops par point (le facteur $2(1-\beta^2)$ est calculé une fois pour toutes) ?
2. Combien d'octets échangés avec la mémoire par point, en supposant que chaque tableau est lu ou écrit
   une fois par point (`p_prev` et `p` lus, `p_next` écrit) ?
3. En déduire l'intensité arithmétique $I$ (flop/octet).
4. Une machine a une crête $P = 40$ GFLOP/s et une bande passante mémoire $\beta_{mem} = 10$ GB/s.
   Calculez $I^* = P / \beta_{mem}$ et la borne $\min(P,\ \beta_{mem} I)$. Ce noyau est-il limité par la mémoire ou par le calcul ?

## TP A — Complexité et langages en 1D (30 min)

**A1.** Mesurez le temps en fonction de $N$ pour les versions C et Fortran :

```bash
./scaling.sh ./waves_c 1001 2001 4001 8001 16001 32001 64001
./scaling.sh ./waves_f 1001 2001 4001 8001 16001 32001 64001
```

La colonne « exposant » est $\log(t_2/t_1) / \log\bigl((N_2-1)/(N_1-1)\bigr)$.

**A2.** La version Python (boucles) est lente : limitez les tailles.

```bash
./scaling.sh "python3 waves_1d.py" 1001 2001 4001
```

**A3.** Écrivez une version **vectorisée** `waves_1d_numpy.py` : remplacez la boucle sur `i` par une expression sur des
tranches de tableaux (`p[1:-1]`, `p[:-2]`, `p[2:]`). Vérifiez que `p(L/2)` est inchangé, puis mesurez
(`./scaling.sh "python3 waves_1d_numpy.py" 1001 8001 32001`).

**Questions A.**
1. Quel exposant obtenez-vous en C ? Est-ce conforme au TD 1 ?
2. Un point isolé peut s'écarter de la tendance : lequel, chez vous ? Que faites-vous avant de conclure ?
3. À $N = 1001$, quel est le rapport entre le temps de Python (boucles) et celui de C ? Entre NumPy vectorisé et C ?
4. Le programme Fortran est plus lent que le programme C, alors qu'ils font le même calcul. Relisez la fin de la
   boucle en temps de chaque programme : que fait C que ne fait pas Fortran ? *(La correction se fait en TP C.)*
5. Calculez les GFLOP/s du programme C à $N = 32001$ (5 flops par point, $n_t$ pas). Comparez à la borne
   du TD 4 : pourquoi la mesure la dépasse-t-elle largement ?

## TP B — 2D, options de compilation, ordre des boucles (25 min)

### B1. Complexité 2D (5 min)

```bash
gfortran -O3 -o tube_2d tube_2d.F90
./scaling.sh "./tube_2d {} 10 -" 25 50 100 200
```

(`tube_2d res t_max sortie` : ici $t_{max} = 10$, et `-` signifie « ne pas écrire de fichier ».)

**Q.** Quel est l'exposant ? Est-ce celui du TD 1 ?

### B2. Options de compilation (10 min)

Compilez le même code avec plusieurs niveaux d'optimisation et mesurez `res = 100`. Écrivez aussi le
champ final pour pouvoir le comparer :

```bash
for f in "-O0" "-O1" "-O2" "-O3"; do
    name=$(echo "$f" | tr -d ' -')
    gfortran $f -o tube_2d_$name tube_2d.F90
    echo -n "$f : "; ./tube_2d_$name 100 10 champ_$name.dat
done
python3 compare_fields.py champ_O0.dat champ_O3.dat
```

**Questions B2.**
1. Quel est le gain entre `-O0` et `-O3` ?
2. Les champs `-O0` et `-O3` sont-ils identiques ? Quel est l'écart relatif ? Qu'en concluez-vous sur l'effet
   des options d'optimisation sur les arrondis ?
3. Demandez au compilateur ce qu'il fait de la boucle **intérieure** du schéma saute-mouton :

   ```bash
   L=$(grep -n 'p_np1(i,j) = 2.0_dp' tube_2d.F90 | cut -d: -f1)
   gfortran -O3 -fopt-info-vec-optimized -fopt-info-vec-missed -c tube_2d.F90 -o /dev/null 2>&1 | grep "tube_2d.F90:$((L-1)):"
   ```

   Est-elle vectorisée ? Que dit le message ? *(Gardez-le : on y revient en B3.)*

### B3. Ordre des boucles (10 min)

Le programme `loop_order` calcule $B = 2A$ sur une matrice $n \times n$ stockée ligne par ligne, avec les deux ordres de boucles.

```bash
gcc -O3 -o loop_order loop_order.c
for n in 128 129 1024 1025 4096 4097; do ./loop_order $n; done
```

**Questions B3.**
1. Quel est le rapport « par colonnes / par lignes » à $n = 4096$ ? **Relancez 3 ou 4 fois** : pour une dimension égale à une
   puissance de 2, la valeur varie beaucoup d'une exécution à l'autre. Donnez une fourchette et reliez-la au TD 3.
2. Comparez $n = 128$ et $n = 129$, puis $4096$ et $4097$. Que remarquez-vous ? *(Indice : à $n = 128$, deux éléments d'une
   colonne sont séparés de $8n = 1024$ octets, une puissance de 2 : ils tombent dans les mêmes emplacements du cache.)*
3. **Expérience.** Dans `tube_2d.F90`, la boucle intérieure du schéma porte sur $j$, le **mauvais** indice pour
   Fortran (cf. TD 3). Intervertissez les deux boucles (`do j` à l'extérieur, `do i` à l'intérieur), recompilez en `-O3`,
   puis comparez avant et après sur deux tailles :

   ```bash
   ./tube_2d 100 10 -        # res = 100, t_max = 10
   ./tube_2d 400 1 -         # res = 400, t_max = 1
   ```

   Quel est le gain ? Le compilateur dit-il autre chose de la boucle intérieure (même commande qu'en B2) ?
   Les champs finaux sont-ils identiques (`compare_fields.py`) ? Pourquoi le gain est-il plus grand à `res = 400` qu'à
   `res = 100` ? *(Reprenez le TD 2.)*

## TP C — Deux optimisations à la main (20 min)

On repart de `waves_f` (1D) et de votre version de `tube_2d` **avec les boucles dans le bon ordre** (B3), compilés en `-O3`. Notez les mesures de référence avant de modifier.

**C1. Éviter les recopies (Fortran 1D, 5 min).** À la fin de chaque pas, `waves_1d.f90` recopie les tableaux
(`p_prev = p`, `p = p_next`), alors que C permute simplement des pointeurs. En Fortran, on permute des
allocations avec `move_alloc(de, vers)` (il faut un tableau temporaire `tmp`) :

```fortran
call move_alloc(p_prev, tmp)
call move_alloc(p,      p_prev)
call move_alloc(p_next, p)
call move_alloc(tmp,    p_next)
```

Modifiez `waves_1d.f90`, vérifiez que `p(L/2)` est inchangé, mesurez à $N = 32001$ et comparez à C.

**C2. Même chose en 2D (5 min).** Appliquez-le à `tube_2d.F90` (`p_nm1 = p_n ; p_n = p_np1`), avec un tableau
temporaire bidimensionnel. Mesurez `./tube_2d 100 10 -`. Comparez les champs finaux (avant/après) avec `compare_fields.py`.

**C3. Précalculer les inverses (5 min, si le temps le permet).** Dans le noyau, `/ dx**2` et `/ dy**2` sont
des divisions, bien plus coûteuses qu'une multiplication. Calculez avant la boucle en temps
`idx2 = 1/dx**2` et `idy2 = 1/dy**2`, remplacez les divisions par `* idx2` et `* idy2`, mesurez, comparez les champs.

**Questions C.**
1. Quel gain pour C1 ? Le programme Fortran rattrape-t-il C ?
2. Quels gains pour C2 et C3, seuls puis cumulés ? Calculez ensuite le gain total depuis la version d'origine
   (avant B3), à `res = 100` et à `res = 400`.
3. **Les champs sont-ils identiques après C2 ? Après C3 ?** Expliquez la différence. *(Que change chaque
   transformation : l'ordre des opérations flottantes, ou seulement l'endroit où l'on range les résultats ?)*
4. Quelle optimisation choisiriez-vous dans un code de recherche, et pourquoi ?

## Bilan (10 min)

Complétez avec vos mesures :

| Question | Votre résultat |
|---|---|
| Exposant 1D / 2D | |
| Rapport Python (boucles) / C à N = 1001 | |
| Gain `-O0` → `-O3` (2D) | |
| Rapport « par colonnes / par lignes » (n = 4096) | |
| Gain de l'inversion des boucles de `tube_2d` (res = 100, res = 400) | |
| Gain C1 (1D) / C2 / C3 / cumulé (2D) | |
| `compare_fields` identique après l'inversion ? C2 ? C3 ? | |

Puis répondez, en une phrase chacune :

1. Pourquoi le schéma d'onde est-il limité par la mémoire plutôt que par le calcul (TD 4) ?
2. Citez deux optimisations qui ne changent pas les résultats et une qui change les arrondis.
3. Pourquoi l'ordre des boucles compte-t-il davantage sur un grand tableau que sur un petit ?

**À suivre** : la mesure de la puissance crête, le modèle roofline et le tiling (TP `01-roofline`).
