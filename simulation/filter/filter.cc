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
      x[i*2].reserve(4000000); 
      x[i*2+1].reserve(4000000); 
      
      // we're actually just reading in a few
      int q = 11000; 
      while (q-- > 0 & !adcs.eof()) {
	adcs >> a >> b; 
	x[i*2+1].push_back(trunc(movepoint(a-32768, 15), 15));
	x[i*2].push_back(trunc(movepoint(b-32768, 15), 15));
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
    h.push_back(trunc(movepoint(hn, 21), 21)); 
  }  


  // now the actual filtering; whee!!!
  vector<signal > yraw(x.size());
  for (int i = 0; i < x.size(); i++) {
    cout << "Filtering channel " << i << endl; 
    yraw[i] = rmac(x[i], h, 25); 
  }
  //yraw[4] = rmac(x[4], h, 25); 
 
  // convergent rounding to 1.15, followed by overflow 
  vector<signal >::iterator chan;
  signal::iterator samp; 
  for (chan = yraw.begin(); chan != yraw.end(); ++chan)
    {
      for(samp = chan->begin(); samp != chan->end(); samp++)
	{
	  *samp = convrnd(trunc(*samp, 25), 15);
	  *samp = overf(*samp, 1); 
	}
    }
  
  // write output
  cout << "Writing output" << endl; 
  boost::format ofname("%s.simoutput.dat");
  ofname % simname;
  ofstream output(ofname.str().c_str()); 
  for (int n = 0; n < yraw[0].size(); n++)
    {
      for (int j = 0; j < 10; j++) {
	output << rshift(yraw[j][n], POINTPOS-15) << ' '; 
      }
      output << endl; 
    }
  //cout << hprint(yraw[4][1000], 10, 19) << endl;
}
