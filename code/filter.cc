#include "filter.h"
#include "fixed.h"
using namespace std; 

signal overf(signal x, int max)
{
  signal y = x;
  signal::iterator yn;
  for (yn = y.begin(); yn != y.end(); ++yn)
    {
      yn->overf(max);       
    }
  return y ; 
}

signal convrnd(signal x, int bits)
{
  signal y = x;
  signal::iterator yn;
  for (yn = y.begin(); yn != y.end(); ++yn)
    {
      yn->convrnd(bits);       
    }
  return y; 
}

signal rmac(const signal & x, const signal& h, int precision)
{
  
  //We pad the input vector with len(h) zeros to make the convolution easier
  
  int xbase = x[0].base();
  cout << "Allocating zeros" << endl; 
  Fixed zero(precision); 
  signal xz(2*h.size() + x.size(), zero); 
  for(int i = 0; i < x.size(); ++i) {
    xz[i+h.size()] = x[i]; 
    
  }
  
  
  signal y(x.size() + h.size()); 

  cout << "Beginning primary loop, of "  << h.size()*xz.size()  << " ops" << endl; 
  for(int n = h.size(); n < y.size(); ++n){
    Fixed yn(0, precision), yp(0, precision); 
    for (int k = 0; k < h.size(); ++k) {
      yp = h[k] * xz[n-k]; 
      yp.trunc(precision); 
      
      yn = yn + yp;
    }
    y[n - h.size()] = yn; 
  }

  return y; 
  
}
