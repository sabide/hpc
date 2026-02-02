############################ -*- Mode: Makefile -*- ###########################
## Makefile --- MPI : TP1 : Environment
##
## Author          : Denis Girou (CNRS/IDRIS) <Denis.Girou@idris.fr>
## 
###############################################################################

# Compiler options and link
include ../../arch/make_inc

OBJS = even_odd.o

# Implicit rule for the compilation
.SUFFIXES: .o .f90
%.o : %.f90
	$(CF95) -c $(FFLAGS_TP1) $<

all: even_odd

even_odd:$(OBJS)
	$(CF95) -o $@ $(OBJS) $(LDFLAGS_TP1)

.PHONY: clean exe

exe : even_odd
#	$(MPIEXEC_TP1) ./even_odd
	sbatch even_odd.slurm

clean:
	rm -f $(OBJS) even_odd core
