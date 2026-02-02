############################ -*- Mode: Makefile -*- ###########################
## Makefile ---  MPI : TP2 : point-to-point communications  - ping-pong
##
## Author          : Denis Girou (CNRS/IDRIS) <Denis.Girou@idris.fr>
##
###############################################################################

# Compilers, options for compilation and link
include ../arch/make_inc

OBJS1 = ping_pong_1.o
OBJS2 = ping_pong_2.o
OBJS3 = ping_pong_3.o

# Implicit rule of compilation
.SUFFIXES: .o .f90
%.o : %.f90
	$(CF95) -c $(FFLAGS_TP2) $<

ping_pong_1: $(OBJS1)
	$(CF95) -o $@ $(OBJS1) $(LDFLAGS_TP2)

ping_pong_2: $(OBJS2)
	$(CF95) -o $@ $(OBJS2) $(LDFLAGS_TP2)

ping_pong_3: $(OBJS3)
	$(CF95) -o $@ $(OBJS3) $(LDFLAGS_TP2)

.PHONY: clean exe1 exe2 exe3

exe1 : ping_pong_1
#	$(MPIEXEC_TP2) ./ping_pong_1
	sbatch ping_pong_1.slurm

exe2 : ping_pong_2
#	$(MPIEXEC_TP2) ./ping_pong_2
	sbatch ping_pong_2.slurm

exe3 : ping_pong_3
#	$(MPIEXEC_TP2) ./ping_pong_3
	sbatch ping_pong_3.slurm

clean:
	rm -f $(OBJS1) $(OBJS2) $(OBJS3) ping_pong_1 ping_pong_2 ping_pong_3 core
