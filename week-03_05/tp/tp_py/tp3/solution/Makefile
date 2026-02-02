############################ -*- Mode: Makefile -*- ###########################
## Makefile --- MPI : TP3 : collectives communications
##
## Author          : Dimitri Lecas (CNRS/IDRIS) <dimitri.lecas@idris.fr>
## 
###############################################################################

# Compiles, options for compilation and link
include ../../arch/make_inc

all: pi.py

.PHONY: exe

exe : pi.py
#	$(MPIEXEC_TP3) python -m mpi4py ./pi.py
	sbatch pi.slurm

