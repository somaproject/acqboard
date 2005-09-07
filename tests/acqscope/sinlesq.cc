/*


Simple project to compute the ieee-based four-parameter model of a sine wave. 

*/

#include <fftw3.h>
#include <iostream>
#include <vector>
#include <math.h>
#include <boost/numeric/ublas/matrix.hpp>
#include <boost/numeric/ublas/io.hpp>
#include "sinlesq.h"

using namespace std; 

namespace ublas = boost::numeric::ublas;


struct sineParams {
  double A; 
  double B;
  double C; 
  double w;
};

sineParams threeParamFit(sineParams init, 
			 ublas::vector<double> &y, 
			 double fs)
{
  
  int N = y.size(); 
  ublas::matrix<double> D0 (N, 3);

  for (int i = 0; i < N; i++){
    double t = i/fs; 
    D0(i, 0) = cos(init.w * t);
    D0(i, 1) = sin(init.w *  t);
    D0(i, 2) = 1.0;
       
  }


  ublas::matrix<double> D0T (N, 3), D0Tprod(N, 3), e2(3, 3); 

  D0T = ublas::trans(D0); 
  D0Tprod = ublas::prod(D0T, D0); 
      

  e2(0, 0) = 1.0; 
  e2(1, 1) = 1.0; 
  e2(2,2) = 1.0; 
  cout << e2 << endl; 
  inverse(D0Tprod, e2); 

  cout << D0Tprod << endl; 
  cout << e2 << endl << endl; 
  ublas::vector<double> v(3); 
  v = ublas::prod(D0T, y); 
  cout << v << endl << endl; 
  ublas::vector<double> x0prime = ublas::prod(e2, v); 
  
  cout << x0prime  ; 

  sineParams s; 
  s.A = x0prime(0); 
  s.B = x0prime(1); 
  s.C = x0prime(2); 
  s.w = init.w; 

  return s; 
  
}  

double findPrimaryFrequency(const std::vector<double> & x, double fs) {
  // returns the greatest spectral component of x
  
  int N = x.size(); 

  
  fftw_complex *out;
  fftw_plan p;


  out = (double (*)[2])fftw_malloc((sizeof(fftw_complex) * N));

  p = fftw_plan_dft_r2c_1d(N, (double*)&x[0], out, FFTW_ESTIMATE);
  fftw_execute(p); /* repeat as needed */

  fftw_destroy_plan(p);

  int pos = 0; 
  double val = 0.0; 
  for (int i = 0; i < N/2; i++){
    double absval = out[i][0]*out[i][0] + out[i][1]*out[i][1]; 
    if (absval > val) {
      pos = i;
      val = absval; 
    }
  }
  fftw_free(out);  
  return double(pos)/N*fs; 

}


int main(void){ 

  int N(1<<14); 

  ublas::vector<double> x(N); 
  double fs = 192000.0; 
  double w = 2000.0; 
  double A, B, C;
  A = 3.2; 
  B = 2.70; 
  C = 4.0; 
  for (int i = 0; i < N; i++){
    double t = i/fs; 
    x[i] = A*cos(t*w) + B * sin(t*w) + C; 
    
  }

  cout << "The frequency is " << w << endl; 
 
  //double detect = findPrimaryFrequency(x, fs); 
  //cout << "We detected a frequency at " << detect << endl; 

  
  ublas::vector<double> x1(N); 
  std::copy(x.begin(), x.end(), x1.begin()); 
  


  sineParams s; 
  s.A = 0.0; 
  s.B = 0.0; 
  s.C = 0.0; 
  s.w = w; 

  s = threeParamFit(s, x1, fs); 
  
  cout << "A = " << s.A << " B = " << s.B << " C = " << s.C << endl; 
}  
  
  
