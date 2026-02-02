############################ -*- Mode: Makefile -*- ###########################
## Makefile --- MPI : TP6 : subdividing a 2D cartesian topology
##
## Author          : Dimitri Lecas (CNRS/IDRIS)
##
###############################################################################

# Compilers, options for compilation and link
include ../../arch/make_inc

OBJS = commsplit.o

# Implicit rule for compilation
.SUFFIXES: .o .c
%.o : %.c
	$(CC) -c $(CFLAGS_TP6) $<

all : commsplit

commsplit: $(OBJS)
	$(CC) -o $@ $(OBJS) $(LDFLAGS_TP6)

.PHONY: clean exe

exe: commsplit
#	$(MPIEXEC_TP6) ./commsplit
	sbatch commsplit.slurm

clean :
	rm -f $(OBJS) commsplit core
