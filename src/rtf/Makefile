CC = gcc
BIN_DIR=../../bin

rtfreader: rtfactn.o rtfreader.o
	$(CC) -o $(BIN_DIR)/rtfreader rtfreader.o rtfactn.o 
	cp $(BIN_DIR)/rtfreader ./
	rm ./*.o

rtfreader.o: rtfreader.c rtfdecl.h rtftype.h
rtfactn.o: rtfactn.c rtfdecl.h rtftype.h

clean:
	rm -f *.o rtfreader
