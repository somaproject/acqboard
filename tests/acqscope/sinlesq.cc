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

  inverse(D0Tprod, e2); 

  ublas::vector<double> v(3); 
  v = ublas::prod(D0T, y); 
  ublas::vector<double> x0prime = ublas::prod(e2, v); 
  

  sineParams s; 
  s.A = x0prime(0); 
  s.B = x0prime(1); 
  s.C = x0prime(2); 
  s.w = init.w; 

  return s; 
  
}  


sineParams fourParamFit(sineParams init, 
			ublas::vector<double> &y, 
			double fs)
{
  
  int N = y.size(); 


  int i = 0; 
  double w = init.w; 
  double A, B, C; 
  ublas::matrix<double> Di (N, 4);  
  
  ublas::vector<double> x(4); 
  x(0) = init.A;
  x(1) = init.B; 
  x(2) = init.C; 
  x(3) = 0.0; 

  ublas::matrix<double> DiT (N, 4), DiTprod(N, 4), e2(4, 4);
 
  while (i < 10) {
    //cout << "Iteration " << i <<  " with " << x << endl;
    A = x(0); 
    B = x(1); 
    C = x(2); 

    w = x(3) + w; 
    
    
    for (int j = 0; j < N; j++){
      double t = j/fs; 
      Di(j, 0) = cos(w * t);
      Di(j, 1) = sin(w *  t);
      Di(j, 2) = 1.0;
      Di(j, 3) = - A * t * sin(w*t) + B * t * cos(w*t); 
    }
    
    
    DiT  = ublas::trans(Di); 

    DiTprod = ublas::prod(DiT, Di); 

    for (int j = 0; j < 4; j++)
      for (int k = 0; k < 4; k++)
	if (j == k){
	  e2(j, k) = 1.0; 
	} else {
	  e2(j, k) = 0.0;
	}
    inverse(DiTprod, e2); 

    ublas::vector<double> v(4); 
    v = ublas::prod(DiT, y); 

    x = ublas::prod(e2, v); 
    //cout << x << endl; 
    i++; 
    
  }

  sineParams s; 
  s.A = x(0); 
  s.B = x(1); 
  s.C = x(2); 
  s.w = w; 

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
  return double(pos)/N*fs*2*3.141592; 

}


int main(void){ 

  int N(1<<19); 

  std::vector<double> x(N); 
  double fs = 192000.0; 
  double w = 2000.0; 
  double A, B, C;
  A = 3.2; 
  B = 2.70; 
  C = 0.0; 
  for (int i = 0; i < N; i++){
    double t = i/fs; 
    x[i] = A*cos(t*w) + B * sin(t*w) + C; 
    
  }

  cout << "The frequency is " << w << endl; 
 
  double detect = findPrimaryFrequency(x, fs); 
  cout << "We detected a frequency at " << detect << endl; 

  
  ublas::vector<double> x1(N); 
  std::copy(x.begin(), x.end(), x1.begin()); 
  


  sineParams s; 
  s.A = 0.0; 
  s.B = 0.0; 
  s.C = 0.0; 
  s.w = detect; 

  s = threeParamFit(s, x1, fs); 
  
  cout << "A = " << s.A << " B = " << s.B << " C = " 
       << s.C << " w=" << s.w <<  endl; 

  s = fourParamFit(s, x1, fs); 
  cout << " With four params fit: "<<endl;
  cout << "A = " << s.A << " B = " << s.B 
       << " C = " << s.C << " w = " << s.w << endl ;
  
}  
  
  
