############################ -*- Mode: Makefile -*- ###########################
## Makefile --- TP7 
## 
## Author          : Denis GIROU (CNRS/IDRIS - France) <Denis.Girou@idris.fr>
## 
###############################################################################

# Compileur, options for compilation and link
include ../../arch/make_inc

OBJS    = read_file.o

# Implicit rule for compilation
.SUFFIXES:
.SUFFIXES: .o .f90
%.o : %.f90
	$(CF95) -c $(FFLAGS_TP7) $<

read_file:data.dat $(OBJS) 
	$(CF95) -o $@ $(OBJS) $(LDFLAGS_TP7)

data.dat:
	cd creation;make clean;make

verification: verification.c file_dei0.dat
	$(CC) verification.c -o verification
	$(EXEC_TP7_VERIF) ./verification
	md5sum -c checkmd5.md5

.PHONY : clean cleanall exe

exe: read_file
#	$(MPIEXEC_TP7) ./read_file
	sbatch read_file.slurm

clean:
	rm -f *.o read_file file*.dat data.dat *.ppm verification core*

cleanall:
	make clean
	rm -f data.dat
