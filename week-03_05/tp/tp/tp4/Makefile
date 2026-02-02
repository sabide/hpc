############################ -*- Mode: Makefile -*- ###########################
## Makefile --- MPI : TP4 : derived datatypes (type_transpose)
##
## Author          : Isabelle Dupays (CNRS/IDRIS) <Isabelle.Dupays@idris.fr>
## 
###############################################################################

# Compileurs, options for compilation and link
include ../arch/make_inc

OBJS = transpose.o

# Implicit rule of compilation
.SUFFIXES: .o .f90
%.o : %.f90
	$(CF95) -c $(FFLAGS_TP4) $<

all : transpose

transpose: $(OBJS)
	$(CF95) -o $@ $(OBJS) $(LDFLAGS_TP4)

.PHONY: clean exe

exe : transpose
#	$(MPIEXEC_TP4) ./transpose
	sbatch transpose.slurm

clean :
	rm -f $(OBJS) transpose core
