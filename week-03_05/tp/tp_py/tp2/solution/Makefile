############################ -*- Mode: Makefile -*- ###########################
## Makefile ---  MPI : TP2 : point-to-point communications  - ping-pong
##
## Author          : Dimitri Lecas (CNRS/IDRIS)
##
###############################################################################

# Compilers, options for compilation and link
include ../../arch/make_inc

.PHONY: exe1 exe2 exe3

exe1 : ping_pong_1.py
#	$(MPIEXEC_TP2) python -m mpi4py ./ping_pong_1.py
	sbatch ping_pong_1.slurm

exe2 : ping_pong_2.py
#	$(MPIEXEC_TP2) python -m mpi4py ./ping_pong_2.py
	sbatch ping_pong_2.slurm

exe3 : ping_pong_3.py
#	$(MPIEXEC_TP2) python -m mpi4py ./ping_pong_3.py
	sbatch ping_pong_3.slurm

