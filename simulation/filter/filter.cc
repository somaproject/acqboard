#include "../../code/filter.h"

#include <iostream>
#include <vector>
#include <fstream>
#include <boost/format.hpp>

using namespace std; 
int main(void)
{

  string simname = "basic";

  vector<signal > x(10); 
  for (int i = 0 ; i < 5; ++i)
    {
      boost::format fname("%s.adcin.%d.dat");
      fname % simname % i;
      ifstream adcs(fname.str().c_str()); 
      cout << "Opening " << fname << endl; 
      int a, b;
      x[i*2].reserve(1000000); 
      x[i*2+1].reserve(1000000); 
      
      while (! adcs.eof()) {
	adcs >> a >> b; 
	x[i*2].push_back(Fixed(a-32768, 16));
	x[i*2+1].push_back(Fixed(b-32768, 16));
      }
    }

  // now x contains the bipolar fixed point values
  signal h;
  h.reserve(200); 
  boost::format hname("%s.filter.dat");
  hname % simname;
  ifstream hfstream(hname.str().c_str()); 
  int hn;  
  while (! hfstream.eof()) {
    hfstream >> hn;
    h.push_back(Fixed(hn, 22)); 
  }  

  // now the actual filtering; whee!!!
  vector<signal > yraw(10);
  for (int i = 0; i < 10; i++) {
    cout << i << endl; 
    yraw[i] = rmac(x[i], h, 24); 
  }
  
}

