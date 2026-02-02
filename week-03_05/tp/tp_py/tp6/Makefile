############################ -*- Mode: Makefile -*- ###########################
## Makefile --- MPI : TP6 : subdividing a 2D cartesian topology
##
## Author          : Dimitri Lecas (CNRS/IDRIS)
##
###############################################################################

# Compilers, options for compilation and link
include ../arch/make_inc

.PHONY: exe

exe: commsplit.py
#	$(MPIEXEC_TP6) python -m mpi4py ./commsplit.py
	sbatch commsplit.slurm
