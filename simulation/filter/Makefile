
filter: filter.o fixed.o filtrun.o
	g++ -pg filtrun.o fixed.o filter.o -o filter

fixed.o: ../../code/fixed.cc ../../code/fixed.h
	g++ -O2 -Wall -pg -c ../../code/fixed.cc

filtrun.o: filter.cc
	g++ -O2 -Wall -pg -c filter.cc -o filtrun.o

filter.o: ../../code/filter.cc ../../code/filter.h
	g++ -O2 -Wall -pg -c ../../code/filter.cc
