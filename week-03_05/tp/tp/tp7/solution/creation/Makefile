############################ -*- Mode: Makefile -*- ###########################
## Makefile --- TP7 MPI
##              Creation of the file data.dat
## 
## Author          : Denis GIROU (CNRS/IDRIS - France) <Denis.Girou@idris.fr>
## 
###############################################################################

# Compileur and option for compilation and link
include ../../../arch/make_inc

OBJS    = creation.o

.SUFFIXES: .o .f90
# Implicit rule for compilation
%.o : %.f90
	$(CF95) -c $(FFLAGS_TP7) $<

creation:$(OBJS)
	$(CF95) -o $@ $(OBJS) $(LDFLAGS_TP7)
	$(EXEC_TP7_CREAT) ./creation
	rm -f $(OBJS) creation core
	cp data.dat ..

clean:
	rm -f *.o creation core

cleanall:
	make clean
	rm -f data.dat ../data.dat
