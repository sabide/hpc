############################ -*- Mode: Makefile -*- ###########################
## Makefile --- T.P. 7 du cours MPI
##              Création of the file data.dat
##
## Auteur          : Denis GIROU (CNRS/IDRIS - France) <Denis.Girou@idris.fr>
##
###############################################################################

# Compilateur et options de compilation et de link
include ../../../arch/make_inc

OBJS    = creation.o

.SUFFIXES: .o .c
# Règle implicite de compilation
%.o : %.c
	$(CC) -c $(CFLAGS_TP7) $<

creation:$(OBJS)
	$(CC) $(OBJS) $(LDFLAGS_TP7) -o $@
	$(EXEC_TP7_CREAT) ./creation
	rm -f $(OBJS) creation core
	cp data.dat ..

clean:
	rm -f *.o creation core

cleanall:
	make clean
	rm -f data.dat ../data.dat
