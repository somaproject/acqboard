all: main
scopearea.o: scopearea.cc scopearea.h
	g++ -c scopearea.cc `pkg-config gtkmm-2.0 --cflags`
main.o: main.cc scopearea.o 
	g++ -c main.cc `pkg-config gtkmm-2.0 --cflags`
main: main.o scopearea.o
	 g++ main.o scopearea.o  -o main `pkg-config gtkmm-2.0 --cflags --libs`
clean:
	rm *.o main
domainserver: domainserver.cc
	g++ domainserver.cc -o domainserver
