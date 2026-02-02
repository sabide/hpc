############################ -*- Mode: Makefile -*- ###########################
## Makefile --- MPI : TP3 : collectives communications
##
## Author          : Dimitri Lecas (CNRS/IDRIS) <dimitri.lecas@idris.fr>
## 
###############################################################################

# Compiles, options for compilation and link
include ../arch/make_inc

OBJS  = pi.o

# Implicit rule for compilation
.SUFFIXES: .o .c
%.o : %.c
	$(CC) -c $(CFLAGS_TP3) $<

all: pi

pi: $(OBJS)
	$(CC) -o $@ $(OBJS) $(LDFLAGS_TP3)

.PHONY : clean exe

exe : pi
#	$(MPIEXEC_TP3) ./pi
	sbatch pi.slurm

clean:
	rm -f $(OBJS) pi core
