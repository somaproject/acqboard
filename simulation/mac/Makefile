
macgen: macgen.o
	g++ -O2 macgen.o -o macgen -lgmpxx -lgmp

macgen.o: ../../code/fixed.h macgen.cc
	g++ -O2 -Wall -c macgen.cc
