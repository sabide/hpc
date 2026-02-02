############################ -*- Mode: Makefile -*- ###########################
## Makefile --- MPI : TP3 : collectives communications
##
## Author          : Dimitri Lecas (CNRS/IDRIS) <Dimitri.Lecas@idris.fr>
##
###############################################################################

# Compileur, options for compilation and link
include ../arch/make_inc

OBJS  = pi.o

# Implicit rule for compilation
.SUFFIXES: .o .f90
%.o : %.f90
	$(CF95) -c $(FFLAGS_TP3) $<

all: pi

pi: $(OBJS)
	$(CF95) -o $@ $(OBJS) $(LDFLAGS_TP3)

.PHONY : clean exe

exe : pi
#	$(MPIEXEC_TP3) ./pi
	sbatch pi.slurm

clean:
	rm -f $(OBJS) pi core
