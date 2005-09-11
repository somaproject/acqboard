
CXX=g++
CFLAGS=  -O2 -DNDEBUG -fpic

all: sinlesq python

sinlesq.o: sinlesq.cc sinlesq.h filters.h
	$(CXX) $(CFLAGS) -O2 -c sinlesq.cc

sinlesqmodule.o: sinlesq.cc sinlesq.h sinlesqmodule.cc
	$(CXX) -fpic -c sinlesqmodule.cc -I/usr/include/python2.3/

python: sinlesqmodule.o sinlesq.o
	g++ -shared sinlesq.o sinlesqmodule.o -lfftw3 -lm  -o sinlesq.so

sinlesq: sinlesq.o
	$(CXX) $(CFLAGS) sinlesq.o -o sinlesq -lfftw3 -lm

clean:
	rm *.o *.so sinlesq
