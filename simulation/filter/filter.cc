#include "../../code/filter.h"

#include <iostream>
#include <vector>
#include <fstream>
#include <algorithm>
#include <iterator>

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
	x[i*2+1].push_back(movepoint(a-32768, 15));
	x[i*2].push_back(movepoint(b-32768, 15));
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
    h.push_back(movepoint(hn, 21)); 
  }  

  // now the actual filtering; whee!!!
  vector<signal > yraw(10);
  for (int i = 0; i < 10; i++) {
    yraw[i] = rmac(x[i], h, 24); 
  }
  
  
  // convergent rounding to 1.15, followed by overflow 
  vector<signal >::iterator chan;
  signal::iterator samp; 
  for (chan = yraw.begin(); chan != yraw.end(); ++chan)
    {
      for(samp = chan->begin(); samp != chan->end(); samp++)
	{
	  *samp =  convrnd(*samp, 16);
	  *samp = overf(*samp, 1); 
	}
    }
  
  // write output
  boost::format ofname("%s.simoutput.dat");
  ofname % simname;
  ofstream output(ofname.str().c_str()); 
  for (int n = 0; n < yraw[0].size(); n++)
    {
      for (int j = 0; j < 10; j++) {
	output << getint(yraw[j][n], 15) << ' '; 
      }
      output << endl; 
    }
}
