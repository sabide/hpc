############################ -*- Mode: Makefile -*- ###########################
## Makefile --- MPI : TP6 : subdividing a 2D cartesian topology 
##                    with MPI_COMM_SPLIT
##
## Author          : Isabelle Dupays (CNRS/IDRIS)
## 
###############################################################################

# Compileurs, options for compilation and link
include ../../arch/make_inc

OBJS = commsplit.o

# Implicut rule for compilation
.SUFFIXES: .o .f90
%.o : %.f90
	$(CF95) -c $(FFLAGS_TP6) $<

all : commsplit

commsplit: $(OBJS)
	$(CF95) -o $@ $(OBJS) $(LDFLAGS_TP6)

.PHONY: clean exe

exe: commsplit
#	$(MPIEXEC_TP6) ./commsplit
	sbatch commsplit.slurm

clean :
	rm -f $(OBJS) commsplit core
