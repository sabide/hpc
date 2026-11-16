# Démo : produit matrice-matrice, roofline et tiling

Produit $C = A \times B$ pour des matrices $N \times N$ stockées ligne par ligne, avec trois
variantes de boucles :

| Fichier | Contenu |
|---|---|
| `matmul_roofline.cpp` | version `ijk` (accès à `B` par colonnes) et version `ikj` (accès contigus), avec calcul de l'intensité arithmétique et des GFLOP/s |
| `matmul_tiled.cpp` | version naïve `ijk` et version avec **tiling** par blocs de taille `BS` |
| `roofline.sh` | balayage en taille de `matmul_roofline`, écrit `roofline_data.dat` |

## Compiler et lancer

```bash
cmake -S . -B build
cmake --build build
./build/matmul_roofline 256            # N = 256
./build/matmul_tiled 1024 32           # N = 1024, blocs de 32
./roofline.sh build/matmul_roofline    # balayage N = 4 ... 256 -> roofline_data.dat
```

Le `CMakeLists.txt` compile en Release avec `-march=native` (ou `-mcpu=native` si indisponible).
Compilez **sur le nœud qui exécutera le code** : l'exécutable peut ne pas tourner sur un autre processeur.

## Modèles d'intensité arithmétique utilisés

$2N^3$ flops dans les deux cas ; le trafic mémoire diffère :

- `ijk` : modèle **pessimiste**, aucune réutilisation, $2N^3$ doubles = $16 N^3$ octets, soit
  $I = 1/8$ flop/octet ;
- `ikj` : modèle **optimiste**, chaque matrice lue ou écrite une fois, $3N^2$ doubles = $24 N^2$ octets,
  soit $I = N/12$ flop/octet.

Ces deux modèles **encadrent** l'intensité réelle. Le TP `../../tp/01-roofline` n'utilise que le modèle
idéal, noyau par noyau.

## Lien avec le TP roofline

Dans le TP, le noyau `matmul` (ordre `ikj`, sans tiling) atteint 40 à 50 % de la crête même quand
la matrice tient dans le cache : chaque FMA de la boucle intérieure fait 2 lectures et 1 écriture.
**Le tiling** (`matmul_tiled.cpp`) réutilise les blocs depuis le cache ; c'est la suite naturelle du TP.

## À savoir

- `matmul_roofline` adapte le nombre de répétitions de la version `ikj` pour mesurer environ 0,3 s
  (au plus 1000 répétitions). La matrice `C` n'est pas remise à zéro entre les répétitions : seuls le temps
  et les GFLOP/s ont un sens, le checksum `ikj` n'est pas comparable à celui de `ijk`.
- Mesures fiables : nœud de calcul réservé, plusieurs exécutions.
