#include <iostream>
#include <vector>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <sys/un.h>
#include <arpa/inet.h>
#include <sstream>

using namespace std; 

extern __inline__ unsigned long long int rdtsc()
{
  unsigned long long int x;
  __asm__ volatile (".byte 0x0f, 0x31" : "=A" (x));
  return x;
}

#define BUFSIZE 24
#define MCNT 1000000

int
main (int argc, char** argv)
{

  int listenfd, connfd;
  struct sockaddr_un servaddr;
  ostringstream output;

  vector<int> connections(20); 
  listenfd = socket(AF_LOCAL, SOCK_STREAM, 0);

  bzero(&servaddr, sizeof(servaddr));
  servaddr.sun_family = AF_LOCAL;
  unlink("/tmp/acqboard.out"); 
  strncpy(servaddr.sun_path, "/tmp/acqboard.out", 18); 
  
  bind(listenfd, (sockaddr *) &servaddr, sizeof(servaddr));

  
  listen(listenfd, 10); 
  int conpos(0); 
  

  unsigned char buffer[BUFSIZE];
  
 
  connections[0] = accept(listenfd, (sockaddr *) NULL, NULL); 
  cout << "Connection established!" << endl; 



  int pos = 0 ; 
  int period = 200; 

  
  while(1) { 
   
    usleep(1000); 
    for (int j = 0; j < 64; j++) {

      for (int i = 1; i < 9; i++) { 
	/*
	int q = (32768*sin(pos * 3.141592*2.0/period)) + (1+(int) (10000.0*rand()/(RAND_MAX+1.0)));
	if (q < -32768) 
	  q = -32768; 
	if (q > 32767)
	  q = 32767; 
	*/
	int q = 327*((pos % 200)-100); 
	short x = (short)q; 
	buffer[i*2+1] = x  % 256;
	buffer[i*2] = x / 256;  
	buffer[1] = 0x5; 
	pos++; 
      }
      
      write(connections[0], buffer, BUFSIZE); 

    }

  }
  
}









