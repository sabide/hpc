# Corrigé — TD/TP 02 ondes (enseignant, dépôt privé uniquement)

Les valeurs mesurées viennent d'un **Apple M3 Pro (ARM, 1 cœur)** avec GCC/gfortran 13 à 16 et Clang.
Ce n'est **pas** la machine des étudiants : ce qui doit se retrouver, ce sont les **rapports**, les
**exposants** et les **raisonnements**, pas les valeurs absolues. Machine non réservée pendant les mesures :
prévoir ±30 % d'une exécution à l'autre. Chaque valeur est le **minimum de 3 exécutions**.

## TD sur papier

**TD 1.** $\Delta x = 1/(N-1)$, $\Delta t = \beta\,\Delta x = 0{,}9/(N-1)$, donc $n_t = T/\Delta t = (N-1)/0{,}9 \approx 1{,}11\,(N-1) \propto N$.
Chaque pas met à jour $N$ points : coût total $O(N \cdot n_t) = O(N^2)$. Si $N$ double, le temps est multiplié par **4**.
Application : $N = 1001$ donne $n_t = 1111$, soit $5 \times 1001 \times 1111 \approx 5{,}6$ Mflop.

En 2D, $\Delta x = \Delta y = 1/res$ et $\Delta t = CFL\,\min(\Delta x,\Delta y)/(c\sqrt2)$ avec $CFL = 0{,}5$ : le nombre de pas vaut
$n_t = t_{max}/\Delta t = 2\sqrt2\,res\,t_{max} \propto res$ (pour `res = 50`, $t_{max} = 100$ : 14142 pas). Le maillage a environ
$10\,res^2$ points : coût **$O(res^3)$**, soit un facteur **8** quand `res` double.

**TD 2.** 1D, $N = 32001$ : $3 \times 32001 \times 8 = 768\,024$ octets, environ 750 Kio.
2D : $3 \times n_x n_y \times 8$ octets. `res = 50` : $3 \times 501 \times 51 \times 8 = 613\,224$ octets (0,6 Mo).
`res = 200` : $3 \times 2001 \times 201 \times 8 \approx 9{,}65$ Mo (9,2 Mio). On dépasse 32 Mio dès
$24\,(10\,res+1)(res+1) > 33\,554\,432$, soit $res \gtrsim 374$.

**TD 3.** (1) C : $i\,n + j$. (2) Fortran : $(i-1) + (j-1)\,n$ (colonnes de $n$ éléments). (3) Boucle intérieure sur $j$ en C : pas de
8 octets ; sur $i$ en C : pas de $8n$ octets. (4) À $n = 4096$, le pas vaut 32 768 octets : chaque accès charge une nouvelle
ligne de cache de 64 octets dont on n'utilise qu'**un double sur 8**, soit **12,5 %** (la ligne est évincée avant d'être réutilisée).

**TD 4.** (1) $2(1-\beta^2)\,p_i$ : 1 multiplication ; $\beta^2(p_{i-1}+p_{i+1})$ : 1 addition + 1 multiplication ;
puis 2 additions/soustractions : **5 flops**. (2) $p^{n-1}$ et $p^n$ lus, $p^{n+1}$ écrit : **24 octets**
($p_{i\pm1}$ viennent du cache). (3) $I = 5/24 \approx 0{,}21$ flop/octet. (4) $I^* = 40/10 = 4$ flop/octet ;
borne $= \min(40,\ 10 \times 0{,}21) = 2{,}08$ GFLOP/s : $I \ll I^*$, le noyau est limité par la **mémoire**.

## TP A — 1D

Temps en secondes (minimum de 3), `-O3` :

| N | C | Fortran | NumPy vectorisé | Python (boucles) |
|---|---|---|---|---|
| 1001 | 0,00028 | 0,00056 | 0,0059 | 0,688 |
| 2001 | 0,00112 | 0,00226 | 0,0149 | 2,75 |
| 4001 | 0,00441 | 0,00909 | 0,0487 | 10,8 |
| 8001 | 0,0306 | 0,0648 | 0,182 | |
| 16001 | 0,0933 | 0,230 | 0,578 | |
| 32001 | 0,369 | 0,713 | 2,00 | |

1. **Exposant ≈ 2** en C à partir de 16001 (1,6 ; 2,0 ; 2,0 ; en 64001 : 1,99) et en Python (rapports ×4,0 puis ×3,9). Conforme au TD 1.
2. **Point irrégulier** : chez moi, $N = 8001$ donne un exposant de 2,85 (reproductible : trois exécutions concordantes, 0,0306 à
   0,0318 s). La cause n'est pas démontrée ; un effet d'associativité du cache est plausible (trois tableaux de 64 Kio), mais je ne
   l'ai pas vérifié. Consigne : **répéter, puis juger la tendance** sur plusieurs points, et ne pas conclure sur un seul.
   Les temps inférieurs à 10 ms sont bruités.
3. À $N = 1001$ : Python / C $= 0{,}688/0{,}00028 \approx$ **2500** ; NumPy / C $\approx$ **21**. À $N = 32001$ : NumPy / C $\approx 5{,}4$
   (le surcoût d'appel de NumPy pèse moins quand les tableaux sont grands). Python en boucles est lent à cause de
   l'interprétation et du coût de l'indexation de scalaires NumPy ; la vectorisation redonne un facteur ~100 ou plus.
4. **Fortran recopie** les tableaux à chaque pas (`p_prev = p`, `p = p_next` : $2N$ lectures et écritures de plus), alors que **C
   permute des pointeurs** : environ **2×** plus lent à $N$ égal. Corrigé en C1.
5. $N = 32001$ : $n_t = 35556$, flops $= 5 \times 32001 \times 35556 \approx 5{,}7 \times 10^9$, temps 0,369 s : **≈ 15 GFLOP/s**, soit
   **7 fois la borne du TD 4** (2,08 GFLOP/s). La borne utilisait la bande passante de la **RAM** ; or les trois tableaux (750 Kio)
   tiennent dans le cache, dont la bande passante est bien plus grande. **Le toit à appliquer dépend du niveau de mémoire qui sert
   les données** (le TP roofline reprend ce point).

## TP B — 2D, options, boucles

**B1.** `res = 25, 50, 100, 200` ($t_{max} = 10$) : 0,009 s ; 0,066 s ; 0,527 s ; 5,71 s. Rapports 7,3 ; 8,0 ; 10,8, exposants
2,8 ; 3,0 ; 3,4. **Tendance vers 3**, conforme au TD 1 ; l'écart pour la plus grande taille vient des effets de cache.

**B2.** `res = 100`, $t_{max} = 10$, gfortran 16 :

| options | temps (s) |
|---|---|
| `-O0` | 2,57 |
| `-O1` | 0,684 |
| `-O2` | 0,636 |
| `-O3` | 0,527 |

1. Gain `-O0` → `-O3` : **×4,9**.
2. `-O0` et `-O1` : champs **identiques**. `-O0` contre `-O2`/`-O3` : écart maximal $7 \times 10^{-15}$, relatif $1 \times 10^{-14}$. Les
   niveaux d'optimisation élevés **changent les arrondis** (fusion multiplication-addition en FMA, réorganisation des opérations), ce qui
   donne des résultats différents à $10^{-14}$ près : un test de non-régression doit utiliser une **tolérance**, pas l'égalité exacte.
3. Sur la boucle intérieure du noyau (ligne $L-1$) : « **couldn't vectorize loop** » (accès avec pas $n_x$ : « not suitable for
   strided load »). Cette boucle porte sur $j$, le mauvais indice pour Fortran.

**B3.** Programme `loop_order`, `-O3` (GCC 13 / Clang donnent le même ordre de grandeur) :

| n | par lignes (GB/s) | par colonnes (GB/s) | rapport |
|---|---|---|---|
| 128 | 78 (GCC) ; 162 (Clang) | 4,5 | 18 (GCC) ; 36 (Clang) |
| 129 | 76 ; 112 | 35 ; 46 | 2,2 ; 2,4 |
| 1024 | 78 | 2,2 | 36 |
| 1025 | 76 | 11 | 7,0 |
| 4096 | 68 | 0,2 à 1,4 | **50 à 300** (variable) |
| 4097 | 67 | 2,7 | 25 (stable) |

1. Rapport de **50 à 300** à $n = 4096$ selon l'exécution (mesuré : 48 une fois, puis 196 à 309 sur six exécutions successives avec le
   même GCC 13 ; la machine n'étant pas isolée, je ne sais pas attribuer cette dérive avec certitude, mais pour une dimension
   puissance de 2 le temps dépend visiblement de la disposition mémoire). **Faire donner une fourchette** et non une valeur.
   Chaque ligne de cache de 64 octets n'est utilisée que pour **un** double sur 8 (TD 3), et chaque accès
   demande une nouvelle ligne de cache. On transfère 8 fois plus de données que nécessaire.
2. **Puissances de 2.** $n = 128 \to 129$ : le rapport tombe de 18-36 à 2,3 ; $4096 \to 4097$ : de 50-300 à 25, et la mesure devient stable. Quand $8n$ est une puissance de 2,
   les éléments d'une colonne se placent dans les **mêmes ensembles** du cache (associativité limitée) et s'évincent mutuellement même
   si le cache est loin d'être plein (*conflict misses*). Consigne : éviter les puissances de 2 comme dimension principale (rembourrage de 1 ou 8).
3. **Expérience** (boucles inversées, `-O3`) :

   | | `res = 100`, $t_{max} = 10$ | `res = 400`, $t_{max} = 1$ |
   |---|---|---|
   | boucles d'origine | 0,53 s | 7,1 s |
   | boucles inversées | 0,294 s (×1,8) | 2,95 s (×2,4) |

   Champs identiques (écart 0) : on change l'ordre de **mises à jour indépendantes**, pas l'arithmétique.
   Le compilateur vectorise alors la boucle intérieure (« loop vectorized using 16 byte vectors »).
   Le gain est plus grand à `res = 400` parce que les trois tableaux (38,5 Mo) ne tiennent plus dans le cache (TD 2) :
   les accès avec saut deviennent des accès RAM. À `res = 100` (2,4 Mo) ils restent dans le cache.

   **Remarque pour l'enseignant.** Dans la **démo** `demos/fortran-2d/tube_2d_ondes.F90`, la taille de la grille est une constante connue
   du compilateur et GCC **intervertit lui-même les boucles** (« loops interchanged ») : l'inversion à la main ne change rien (0,69 s contre
   0,61 s). Dans le programme du TP, la taille vient de la ligne de commande et le compilateur ne le fait plus : ne pas compter sur lui.

## TP C — optimisations (mesures à partir de la version aux boucles inversées)

| variante | `res = 100`, $t = 10$ | `res = 400`, $t = 1$ | écart du champ |
|---|---|---|---|
| référence d'origine (B2) | 0,53 s | 7,10 s | |
| boucles inversées (B3) | 0,294 s | 2,95 s | 0 |
| + rotation des allocations (C2) | 0,177 s | 1,83 s | **0** |
| + inverses précalculés (C3) | 0,268 s | 2,44 s | $5 \times 10^{-15}$ |
| + rotation + inverses | **0,147 s** | **1,45 s** | $5 \times 10^{-15}$ |

**C1.** 1D, $N = 32001$ : Fortran 0,709 s → **0,377 s** avec `move_alloc`, contre 0,368 s pour C : Fortran rattrape C. `p(L/2)` inchangé.

1. Gain C1 : ×1,9 ; **Fortran = C** une fois les recopies supprimées.
2. Seuls : C2 ×1,7 à ×1,6 ; C3 ×1,1 à ×1,2. Cumulés : ×2,0 par rapport aux boucles inversées. Depuis l'origine :
   **×3,6** à `res = 100` et **×4,9** à `res = 400`. Les gains ne s'additionnent pas : ils se **multiplient** (0,294 → 0,177 → 0,147) ;
   la dernière optimisation pèse moins (le noyau est devenu plus limité par la mémoire que par les divisions).
3. **Boucles inversées et rotation : champs identiques.** Elles ne changent ni les opérations flottantes ni leur ordre : seulement l'ordre
   de parcours de mises à jour indépendantes et l'endroit où l'on range les résultats. **Inverses précalculés : écart de $5 \times 10^{-15}$**
   (relatif $7{,}5 \times 10^{-15}$) : $a / b$ et $a \cdot (1/b)$ n'arrondissent pas de la même façon (deux arrondis au lieu d'un). Rappel :
   l'addition et la multiplication flottantes ne sont pas associatives ; ici, c'est la division qu'on remplace.
4. On privilégie les optimisations qui **préservent le résultat** (ordre des boucles, rotation) : elles se valident par égalité exacte.
   On adopte les autres (inverses, `-ffast-math`) en connaissance de cause, avec des tests à tolérance et une documentation.

## Bilan

1. $I = 5/24 \approx 0{,}21 \ll I^*$ : 3 tableaux touchés pour 5 opérations ; la mémoire limite avant le calcul.
2. Sans changement de résultat : inversion des boucles, rotation des allocations (et `-O0` → `-O1`). Qui change les arrondis :
   inverses précalculés (aussi `-O2`/`-O3` par la fusion en FMA, et `-ffast-math`).
3. Sur un petit tableau, tout tient dans le cache : les accès avec saut ne coûtent presque rien ; sur un grand tableau, chaque
   ligne chargée n'est utilisée que pour 1/8 de son contenu et vient de la RAM.

## Notes pour l'enseignant

- **Validé** : tous les programmes compilent avec `-Wall` et s'exécutent avec `-fcheck=all` (contrôle des bornes) sans erreur, et
  `p(L/2)` est identique en C, Fortran, Python et NumPy (6 décimales). `tube_2d.F90` reproduit **octet pour octet** `p_final.dat` de la
  démo (même noyau). **Non testé sur Zen (x86)** : à faire avant la séance (FMA sans `-march=native`, modules `gcc`, `python`).
- **Durées** : Python à 1001, 2001 et 4001 prend environ 14 s au total ; 2D `res = 400`, $t_{max} = 1$ environ 7 s ; le TP A et le TP B sont
  tendus pour 30 et 25 minutes si les étudiants compilent et recopient à la main : prévoir de couper A3 (NumPy) ou C3 (inverses) si besoin.
- **Les codes de démo et ceux du TP diffèrent légèrement** : la démo Python fait un pas de moins (`range(1, nt)`) et utilise `int(T/dt)` ;
  le TP unifie `nt = int(T/dt + 0.5)` et `nt` pas pour les quatre versions, afin que les résultats coïncident.
- **Fortran** : sortie de temps avec un entier 64 bits (`system_clock`), sinon la résolution est trop grossière pour les petits $N$.
- **Compilateur** : le comportement du compilateur varie. L'inversion automatique des boucles observée sur la démo (tailles constantes) peut
  se produire aussi dans d'autres cas : si les étudiants ne voient aucun gain en B3, vérifier avec `-fopt-info-loop-optimized`.
