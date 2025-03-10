# Projet calcul paralléle 2024/2025

## Maitriser son environnement de développement
cloner le dépôt pour récupérer les sources
Compiler et installer les libraries hdf5 et decomp2d.
On utilisera le répertoire $HOME/local/projet/

```shell
module  load intel/oneapi_2024.1.0.596 cmake/3.30.3-gcc12
```

### compilation de la librairie ```hdf5```

On souhaite compiler la librairie hdf5 qui va nous permettre d'écrire en paralléle des données.  

```shell
wget https://github.com/HDFGroup/hdf5/releases/download/hdf5_1.14.6/hdf5-1.14.6.tar.gz
tar xzvf hdf5-1.14.6.tar.gz
cd hdf5-1.14.6/
mkdir build
cd build/
CC=icx FC=ifx cmake -DHDF5_ENABLE_PARALLEL=ON -DHDF5_BUILD_FORTRAN=ON  -DCMAKE_INSTALL_PREFIX=$HOME/local/projet/hdf5/ ..
make -j 32
make install
```
### compilation de la librairie ```decomp2d```
La librairie ```decomp2d``` a été introduite en cours. Elle permet de disctribuer des tableaux 3d sur une grille de processeurs 2d. Il suffit de suivre les instructions suivantes pour son installation.


```shell
tar xf 2decomp-fft-2.0.1.tar
cd 2decomp-fft-2.0.1/
mkdir build
cd build/
CC=icx FC=ifx cmake -DCMAKE_INSTALL_PREFIX=/home/sabide/local/projet/decomp2d/ ..
make 
make install 
```

## Prendre en main la librairie decomp2d
L'objectif de cette partie est de prendre en main la librairie ```decomp2d```. Pour le principe de fonctionnement il faut se référer à la documentation de la librairie.
Le reperoitre ```derivatives``` contient toute les instructions pour implémenter la technique de décomposition en pinceaux (decomp2d).
1. Adpater le contenu pour compiler le projet.
2. Implémenter le calcul de $\Phi - \delta^2 \Phi$
3. Discuter les courbes de scaling en distinguant communications et calculs.

PS. Implémenter == écrire du code qui compile et validé.

## La méthode du gradient conjugué... 
Dans cette partie, je vous propose de résoudre $\Phi - \delta^2 \Phi = S$ sur un domaine périodique.
1. Implémenter le solveur itératif gradient conjugué.
2. Discuter les courbes de scaling.

## La méthode du gradient conjugué avec des communications points à points (pour les plus motivés)
La librairie ```decomp2d``` est coûteuse en terme de coût CPU. Nous allons chercher une optimisation du code en réduisant les temps de communication. Pour cela il faut établir un schéma de communication point à point sur la structure de donnée de offerte par ```decomp2d```.
1. établisser un schéma de communications P2P en utilisant ```MPI_Type_create_subarray```.
2. vérifier que le calcul du résidu est correct.
3. implémenter la méthode du gradient conjugé et donner les courbes de scaling.
4. proposer et implémenter un recouvrement des communication par du calcul.





