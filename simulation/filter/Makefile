
filter: filter.o  filtrun.o
	g++ -O2 filtrun.o filter.o -o filter -lgmpxx -lgmp

filtrun.o: filter.cc
	g++ -O2 -Wall -c filter.cc -o filtrun.o

filter.o: ../../code/filter.cc ../../code/filter.h ../../code/fixed.h
	g++ -O2 -Wall -c ../../code/filter.cc
