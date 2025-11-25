# Calculer sur Azzurra
Ce document vous détail comment se connecter à azzura, comment compiler et comment lancer un job interactif.


## 1. Se connecter à AZZURRA

1. Installez et lancez le client VPN Cisco AnyConnect. (voir dans le repertoire 3rd)

2. Configurez-le avec :
   * Serveur : `open.unice.fr`.
   * Nom d’utilisateur : votre login universitaire suivi de `@hpc`. 
   * Mot de passe : celui de votre compte universitaire 

4. Une fois le VPN actif, connectez-vous au cluster comme dans la section précédente (ssh).
   ```bash
   $ ssh -i ~/.ssh/id_ed25519 votre_login@login-hpc.univ-cotedazur.fr
   ```
Vous pouvez aussi ajouter les lignes suivantes :
   ```bash
Host azzurra
        HostName login-hpc.univ-cotedazur.fr
        IdentityFile ~/.ssh/id_ed25519
        User votre_login
   ```
au fichier `~/.ssh/config`. Ainsi vous pourrez directement vous connecter à AZZURRA via la commande :
   ```bash
   $ ssh azzurra
   ```

## 2. Compiler sur AZZURRA

### 2.1. Pourquoi parler « d’environnement » en HPC ?

Sur une machine personnelle, on a souvent **un seul compilateur** (par exemple `gcc`) et quelques bibliothèques installées « en dur » dans le système.  
Sur un cluster HPC comme **Azzurra**, c’est très différent :

- plusieurs **compilateurs** coexistent (GNU, Intel, AOCC, NVHPC, …) avec **plusieurs versions** de chacun ; 
- il y a de nombreuses **bibliothèques** (MPI, BLAS, LAPACK, FFTW, HDF5, NetCDF, CUDA, etc.) parfois en plusieurs variantes optimisées ; 
- les utilisateurs **n’ont pas les droits administrateur**, donc on ne peut pas « installer » les choses comme sur son laptop.

Pour gérer tout ça proprement, Azzurra utilise le système de **modules** (Lmod) qui permet d’**activer un environnement logiciel** : charger un module va modifier vos variables (`PATH`, `LD_LIBRARY_PATH`, `CPATH`, …) pour pointer vers la bonne version du compilateur et des bibliothèques.

L’idée clé :

- vous **choisissez un environnement** (par ex. « Intel 2025 + OpenMPI + FFTW »),  
- vous **compilez** votre code dans cet environnement.

---

### 2.2. Découvrir et charger les modules

Une fois connecté sur `login-hpc` :

```bash
# Voir les modules essentiels disponibles
module avail

# Chercher un module particulier (ex : intel)
module spider intel
```

Sur Azzurra, il existe par exemple un module `intel` (Intel Parallel Studio / Intel oneAPI):

```bash
# Nettoyer l'environnement de modules
module purge

# Charger le compilateur Intel (toutes versions confondues)
module load intel

# Optionnel : vérifier l'environnement actif
module list
```

> ⚠️ *Bon réflexe* : toujours faire `module purge` puis charger explicitement ce dont vous avez besoin avant de compiler, pour éviter des mélanges de versions.

---

### 2.3. Exemple : compiler avec le compilateur Intel

Les compilateurs Intel disponibles via le module `intel` incluent les compilateurs C/C++ et Fortran, avec les bibliothèques MPI associées. ([calculs.univ-cotedazur.fr][1])

Historiquement, les commandes sont :

* `icc` : compilateur C Intel (ancien nom, encore présent sur certains environnements)
* `icpc` : compilateur C++ Intel
* `ifort` : compilateur Fortran Intel

Sur les versions récentes (oneAPI), les nouveaux noms sont :

* `icx` : C/C++
* `ifx` : Fortran

Suivant la version du module `intel` chargée, les deux générations peuvent coexister. Vous pouvez tester simplement :

```bash
which icc
which icx
which ifort
which ifx
```

Pour tester par vous-même, créez un fichier `hello_intel.c` :
```c
#include <stdio.h>

int main(void) {
    printf("Hello Azzurra (Intel) !\n");
    return 0;
}
```
Sur la frontale (pour la compilation **uniquement**) :

```bash
module purge
module load intel

# Exemple avec l’ancien compilateur C Intel
icc -O3 -xHost hello_intel.c -o hello_intel

# OU, si votre module fournit plutôt icx :
icx -O3 -march=native hello_intel.c -o hello_intel
```

Options utilisées (voir week-02):

* `-O3` : optimisation agressive, adaptée aux codes de calcul intensif ;
* `-xHost` (icc) / `-march=native` (icx) : génère du code optimisé pour l’architecture CPU de la machine.

De même un exemple minimal en pour tester la compilation fortran est généralement `hello_intel.f90` :

```fortran
program hello_intel
  print *, "Hello Azzurra (Intel Fortran)!"
end program hello_intel
```
qui se compile en chargeant un compilateur intel et en compilant:
```bash
module purge
module load intel

# Ancien compilateur Fortran Intel :
ifort -O3 -xHost hello_intel.f90 -o hello_intel_f90

# OU, avec le nouveau compilateur :
 ifx -O3 -march=native hello_intel.f90 -o hello_intel_f90
```

---
Compris — voici **tout d’un bloc**, sans encadré externe, entièrement en Markdown :

---

## 3. Mode interactif : `salloc` vs `srun` 

Sur Azzurra, le gestionnaire de ressources est **Slurm**. Pour tester un programme ou travailler temporairement sur un nœud de calcul, il est possible d’ouvrir une session interactive. Deux commandes sont principalement utilisées : `salloc` et `srun`.

### 3.1 Allouer une ressource `salloc`

`salloc` sert à **réserver** des ressources pour une durée donnée.
Il crée une allocation, mais ne lance aucune commande automatiquement.
Une fois l’allocation accordée, on exécute ensuite manuellement des commandes (souvent via `srun`).

### 3.2 Exécuter en allouant une ressource `srun`

`srun` permet à la fois de **réserver et exécuter** une commande.
Pour obtenir un terminal interactif directement sur un nœud de calcul, on ajoute généralement :

```bash
--pty bash -i
```

Dans la majorité des cas simples, `srun` est donc plus pratique que `salloc`.

### 3.3 Exemple : session interactive sur un nœud Intel ou AMD

```bash
srun -A training --constraint=intel --nodes=1 --ntasks=1 --time=01:00:00 --pty bash -i
```

**Explications :**

* compte projet : `training`
* nœud demandé : `intel`
* 1 nœud, 1 tâche
* durée maximale 1 h
* ouverture immédiate d’un terminal interactif sur le nœud

Une fois la session ouverte, vous pouvez exécuter votre code, par exemple :

```bash
./mon_executable
```

Pour utiliser un noeud AMD=
```bash
srun -A training --constraint=amd --nodes=1 --ntasks=1 --time=01:00:00 --pty bash -i
```

La seule différence est la contrainte matérielle (`amd` au lieu de `intel`).

### 3.4. Quand utiliser `salloc` ?

Vous préférerez `salloc` lorsque vous souhaitez :

* réserver un nœud,
* prendre le temps d’ajuster votre environnement,
* lancer plusieurs commandes successives via `srun`.

Exemple typique :

```bash
salloc -A training --nodes=1 --ntasks=1 --time=01:00:00
srun hostname
srun ./mon_executable
```

Pour un usage ponctuel et simple, `srun --pty bash -i` reste le plus direct.
