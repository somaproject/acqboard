fixedtest: fixedtest.o filter.o
	g++ -g fixedtest.o filter.o -o fixedtest -lgmpxx -lgmp -lboost_unit_test_framework

fixedtest.o: fixedtest.cc fixed.h
	g++ -Wall -g -c fixedtest.cc

filter.o: filter.cc filter.h fixed.h
	g++ -Wall -g -c filter.cc
