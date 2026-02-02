############################ -*- Mode: Makefile -*- ###########################
## Makefile --- MPI Hands-On session: Poisson's equation
##
## Auteur          : Dimitri Lecas (CNRS/IDRIS)
###############################################################################
SHELL := /bin/bash
# Include Machine-specific Parameters
include ../arch/make_inc

OBJS1 = read.o
OBJS2 = exact_solution.o

# Makefile Rules
all: read exact_solution

read: $(OBJS1)
	$(CC) $(OBJS1) $(LDFLAGS_TP8) -o $@

exact_solution: $(OBJS2)
	$(CC) $(OBJS2) $(LDFLAGS_TP8) -o $@

fort.11: read data.dat
	$(EXEC_TP8_VERIF) ./read

.PHONY: exe clean verification

exe data.dat: poisson.py poisson.data
	rm -f data.dat
#	$(MPIEXEC_TP8) python -m mpi4py ./poisson.py
	sbatch poisson.slurm

verification: fort.11 exact_solution
	$(EXEC_TP8_VERIF) ./exact_solution

clean:
	rm -f $(OBJS) $(OBJS1) $(OBJS2) $(OBJS3) poisson exact_solution read *.mod core data.dat fort.10 fort.11
