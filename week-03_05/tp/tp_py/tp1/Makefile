############################ -*- Mode: Makefile -*- ###########################
## Makefile --- MPI : TP1 : Environment
##
## Author          : Dimitri Lecas (CNRS/IDRIS) <dimitri.lecas@idris.fr>
###############################################################################

include ../arch/make_inc

.PHONY: exe

exe : even_odd.py
#	$(MPIEXEC_TP1) python -m mpi4py ./even_odd.py
	sbatch even_odd.slurm
