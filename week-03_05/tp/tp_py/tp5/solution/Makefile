############################ -*- Mode: Makefile -*- ###########################
## Makefile --- MPI : TP5 : collectives communications
##
## Author          : Dimitri LECAS (CNRS/IDRIS)
##
###############################################################################

# Compileurs, options for compilation and link
include ../../arch/make_inc

.PHONY: exe

exe: matrix_products.py
#	$(MPIEXEC_TP5) python -m mpi4py ./matrix_products.py
	sbatch matrix_products.slurm
