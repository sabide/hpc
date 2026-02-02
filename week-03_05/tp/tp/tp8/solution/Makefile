############################ -*- Mode: Makefile -*- ###########################
## Makefile --- MPI Hands-On session: Poisson's equation
##
## Author  : Isabelle Dupays (CNRS/IDRIS) <Isabelle.Dupays@idris.fr>
###############################################################################
SHELL := /bin/bash
# Include Machine-specific Parameters
include ../../arch/make_inc

OBJS = type_params.o parallel.o compute_poisson.o poisson.o
OBJS1 = read.o
OBJS2 = exact_solution.o
OBJS3 = type_params.o parallel.o compute_poisson.o poisson_nonblocking.o

# Implicit Rules
.SUFFIXES: .o .f90
%.o : %.f90
	$(CF95) -c  $(FFLAGS_TP8) $<

# Makefile Rules
default: poisson

all: poisson read exact_solution

poisson: $(OBJS)
	$(CF95) -o $@ $(OBJS) $(LDFLAGS_TP8)

poisson_nonblocking: $(OBJS3)
	$(CF95) -o $@ $(OBJS3) $(LDFLAGS_TP8)

read: $(OBJS1)
	$(CF95) -o $@ $(OBJS1) $(LDFLAGS_TP8)

exact_solution: $(OBJS2)
	$(CF95) -o $@ $(OBJS2) $(LDFLAGS_TP8)

fort.11: read data.dat
	$(EXEC_TP8_VERIF) ./read

.PHONY: exe clean verification

exe data.dat: poisson poisson.data
	rm -f data.dat
#	$(MPIEXEC_TP8) ./poisson
	sbatch poisson.slurm

verification: fort.11 exact_solution
	$(EXEC_TP8_VERIF) ./exact_solution

clean:
	rm -f $(OBJS) $(OBJS1) $(OBJS2) $(OBJS3) poisson poisson_nonblocking exact_solution read *.mod core data.dat fort.10 fort.11
