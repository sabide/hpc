############################ -*- Mode: Makefile -*- ###########################
## Makefile --- MPI Hands-On session: Poisson's equation
##
## Auteur          : Dimitri Lecas (CNRS/IDRIS)
###############################################################################
SHELL := /bin/bash
# Include Machine-specific Parameters
include ../arch/make_inc

OBJS = parallel.o compute.o poisson.o
OBJS1 = read.o
OBJS2 = exact_solution.o

# Implicit Rules
.SUFFIXES: .o .c
%.o : %.c
	$(CC) -c  $(CFLAGS_TP8) $<

# Makefile Rules
default: poisson

all: poisson read exact_solution

poisson: $(OBJS)
	$(CC) $(OBJS) $(LDFLAGS_TP8) -o $@

read: $(OBJS1)
	$(CC) $(OBJS1) $(LDFLAGS_TP8) -o $@

exact_solution: $(OBJS2)
	$(CC) $(OBJS2) $(LDFLAGS_TP8) -o $@

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
	rm -f $(OBJS) $(OBJS1) $(OBJS2) $(OBJS3) poisson exact_solution read *.mod core data.dat fort.10 fort.11
