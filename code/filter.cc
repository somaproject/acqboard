#include "fixed.h"
#include "filter.h"
using namespace std; 


signal overf(signal x, int max)
{
  signal y = x;
  signal::iterator yn;
  for (yn = y.begin(); yn != y.end(); ++yn)
    {
      *yn = overf(*yn, max);       
    }
  return y ; 
}

signal convrnd(signal x, int bits)
{
  signal y = x;
  signal::iterator yn;
  for (yn = y.begin(); yn != y.end(); ++yn)
    {
      *yn  = convrnd(*yn, bits);       
    }
  return y; 
}

signal rmac(const signal & x, const signal& h, int precision)
{
  
  //We pad the input vector with len(h) zeros to make the convolution easier
  
  Fixed  zero(0); 
  signal xz(2*h.size() + x.size(), zero); 
  for(int i = 0; i < x.size(); ++i) {
    xz[i+h.size()] = x[i]; 
    
  }
  
  
  signal y(x.size() + h.size()); 

  for(unsigned int n = h.size(); n < y.size(); ++n){
    Fixed yn(0), yp(0); 
    for (unsigned int k = 0; k < h.size(); ++k) {
      Fixed yp = mult(h[k],  xz[n-k]); 
      
      yn = trunc(yp, precision) + yn;
      
     if (yn != trunc(yn, precision)) 
	cout << "precision error in rmac;" << yn << " != " << trunc(yn, precision) << endl;
    }
    y[n - h.size()] = yn; 
  }

  return y; 
  
}
