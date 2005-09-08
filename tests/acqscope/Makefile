
CCX=g++-3.4
CFLAGS=-g  -DNDEBUG -O2

all: main
scopearea.o: scopearea.cc scopearea.h
	$(CXX) $(CFLAGS) -c scopearea.cc `pkg-config gtkmm-2.4 --cflags  sigc++-2.0`
scope.o: scopearea.o scope.cc scope.h
	$(CXX) $(CFLAGS) -c scope.cc `pkg-config gtkmm-2.4 --cflags  sigc++-2.0`
main.o: main.cc scope.o
	$(CXX) $(CFLAGS) -c main.cc `pkg-config gtkmm-2.4 --cflags  sigc++-2.0`
main: main.o scopearea.o scope.o sinlesq.o thdn.o
	 $(CXX) $(CFLAGS) main.o scopearea.o scope.o sinlesq.o thdn.o  -o main `pkg-config gtkmm-2.4 --cflags --libs` -lfftw3 -lm

sinlesq.o: sinlesq.cc sinlesq.h
	$(CXX) $(CFLAGS) -O2 -c sinlesq.cc  -DNDEBUG

thdn.o: thdn.cc thdn.h
	$(CXX) $(CFLAGS) -O2 -c thdn.cc -DNDEBUG

sinlesq: sinlesq.o
	$(CXX) $(CFLAGS) sinlesq.o -o sinlesq -lfftw3 -lm
clean:
	rm *.o main sinlesq
domainserver: domainserver.cc
	$(CXX) $(CFLAGS) domainserver.cc -o domainserver
