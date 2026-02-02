############################ -*- Mode: Makefile -*- ###########################
## Makefile ---  MPI : TP2 : point-to-point communications  - ping-pong
##
## Author          : Dimitri Lecas (CNRS/IDRIS)
##
###############################################################################

# Compilers, options for compilation and link
include ../../arch/make_inc

OBJS1 = ping_pong_1.o
OBJS2 = ping_pong_2.o
OBJS3 = ping_pong_3.o

# Implicit rule of compilation
.SUFFIXES: .o .c
%.o : %.c
	$(CC) -c $(CFLAGS_TP2) $<

ping_pong_1: $(OBJS1)
	$(CC) -o $@ $(OBJS1) $(LDFLAGS_TP2)

ping_pong_2: $(OBJS2)
	$(CC) -o $@ $(OBJS2) $(LDFLAGS_TP2)

ping_pong_3: $(OBJS3)
	$(CC) -o $@ $(OBJS3) $(LDFLAGS_TP2)

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
