# HPC

# Séance 1

Introduction + fortran 90 
Sur machine sans azzura

# Séance 2
comment se conncter sur la machine?
https://calculs.univ-cotedazur.fr/?page_id=100 ?
problème de connection séeance annulée


# Séance 3
## connexion machine

## compiler une librarie
### Exemple modéle
Dans cet exemple on va compiler uen librairie (hdf5) pour exporter des données au format binaire standard.

module load  gcc/9.3.0 cmake/3.20.1-gcc9 
wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.14/hdf5-1.14.3/src/hdf5-1.14.3.tar.gz
tar xzvf hdf5-1.14.3.tar.gz
cd hdf5-1.14.3/
mkdir build
cd build/
CC=gcc FC=gfortran cmake .. -DCMAKE_INSTALL_PREFIX=~/etu_local/hdf5/ -DHDF5_BUILD_FORTRAN=ON
make -j 32 install 
cd ../../

ensuite compiler l'exemple hdf5

cd /home/sabide/tp_environnement-HPC/hdf5/
mkdir build
cd build
cmake .. -DHDF5_ROOT=/home/sabide/etu_local/hdf5/ -DCMAKE_VERBOSE_MAKEFILE=ON
./export_3d_hdf5

Exploiter les données avec python

### A vous de jouer avec FFTW
wget http://www.fftw.org/fftw-3.3.10.tar.gz
tar xzvf fftw-3.3.10.tar.gz 
cd fftw-3.3.10/
mkdir build
CC=gcc FC=gfortran cmake .. -DCMAKE_INSTALL_PREFIX=/home/sabide/etu_local/fftw

