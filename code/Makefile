fixedtest: fixedtest.o fixed.o filter.o
	g++ -g fixedtest.o fixed.o filter.o -o fixedtest

fixed.o: fixed.cc fixed.h
	g++ -Wall -g -c fixed.cc

fixedtest.o: fixedtest.cc
	g++ -Wall -g -c fixedtest.cc

filter.o: filter.cc filter.h
	g++ -Wall -g -c filter.cc
