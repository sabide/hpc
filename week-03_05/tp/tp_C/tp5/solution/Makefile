############################ -*- Mode: Makefile -*- ###########################
## Makefile --- MPI : TP5 : collectives communications
##
## Author          : Dimitri LECAS (CNRS/IDRIS)
##
###############################################################################

# Compileurs, options for compilation and link
include ../../arch/make_inc

OBJS = matrix_products.o

# Implicit rule for compilation
.SUFFIXES: .o .c
%.o : %.c
	$(CC) -c $(CFLAGS_TP5) $<

all : matrix_products

matrix_products: $(OBJS)
	$(CC) -o $@ $(OBJS) $(LDFLAGS_TP5)

.PHONY: clean exe

exe: matrix_products
#	$(MPIEXEC_TP5) ./matrix_products
	sbatch matrix_products.slurm

clean:
	rm -f $(OBJS) matrix_products core
