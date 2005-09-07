all: main
scopearea.o: scopearea.cc scopearea.h
	g++ -c scopearea.cc `pkg-config gtkmm-2.0 --cflags`
scope.o: scopearea.o scope.cc scope.h
	g++ -c scope.cc `pkg-config gtkmm-2.0 --cflags`
main.o: main.cc scope.o
	g++ -c main.cc `pkg-config gtkmm-2.0 --cflags`
main: main.o scopearea.o scope.o
	 g++ main.o scopearea.o scope.o  -o main `pkg-config gtkmm-2.0 --cflags --libs`

sinlesq.o: sinlesq.cc
	g++ -c sinlesq.cc 
sinlesq: sinlesq.o
	g++ sinlesq.o -o sinlesq -lfftw3 -lm
clean:
	rm *.o main
domainserver: domainserver.cc
	g++ domainserver.cc -o domainserver
