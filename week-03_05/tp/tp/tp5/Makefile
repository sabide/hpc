############################ -*- Mode: Makefile -*- ###########################
## Makefile --- MPI : TP5 : collectives communications
##
## Author          : Isabelle Dupays (CNRS/IDRIS)
## 
###############################################################################

# Compileurs, options for compilation and link
include ../arch/make_inc

OBJS = matrix_products.o

# Impicit rule for compilation
.SUFFIXES: .o .f90
%.o : %.f90
	$(CF95) -c $(FFLAGS_TP5) $<

all : matrix_products

matrix_products: $(OBJS)
	$(CF95) -o $@ $(OBJS) $(LDFLAGS_TP5)

.PHONY: clean exe

exe: matrix_products
#	$(MPIEXEC_TP5) ./matrix_products 48
	sbatch matrix_products.slurm

clean:
	rm -f $(OBJS) matrix_products core
