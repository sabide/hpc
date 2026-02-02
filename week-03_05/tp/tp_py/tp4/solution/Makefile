############################ -*- Mode: Makefile -*- ###########################
## Makefile --- MPI : TP4 : derived datatypes (type_transpose)
##
## Author          : Dimitri LECAS (CNRS/IDRIS) <dimitri.lecas@idris.fr>
##
###############################################################################

# Compilers, options for compilation and link
include ../../arch/make_inc

.PHONY: exe

exe : transpose.py
#	$(MPIEXEC_TP4) python -m mpi4py ./transpose.py
	sbatch transpose.slurm
