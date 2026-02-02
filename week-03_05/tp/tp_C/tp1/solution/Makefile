############################ -*- Mode: Makefile -*- ###########################
## Makefile --- MPI : TP1 : Environment
##
## Author          : Dimitri Lecas (CNRS/IDRIS) <dimitri.lecas@idris.fr>
###############################################################################

# Compiler options and link
include ../../arch/make_inc

OBJS = even_odd.o

# Implicit compil rule
.SUFFIXES: .o .c
%.o : %.c
	$(CC) -c $(CFLAGS_TP1) $<

all: even_odd

even_odd:$(OBJS)
	$(CC) -o $@ $(OBJS) $(LDFLAGS_TP1)

.PHONY: clean exe

exe : even_odd
#	$(MPIEXEC_TP1) ./even_odd
	sbatch even_odd.slurm

clean:
	rm -f $(OBJS) even_odd core
