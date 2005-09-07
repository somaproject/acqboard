/*

Simple project to compute the ieee-based four-parameter model of a sine wave. 

*/

#include <fftw3.h>
#include <iostream>
#include <fstream>

#include <vector>
#include <math.h>
#include <stdlib.h>
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
 
  while (i < 500) {
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

void normalize(ublas::vector<double> x) {
  
  double s = ublas::sum(x); 
  x = x/s; 
  
}

double findPrimaryFrequency(ublas::vector<double> & xin, double fs) {
  // returns the greatest spectral component of x
  // NOTE: will return zero (DC) if the input is not zero-mean

  std::vector<double> x(xin.size()); 
  std::copy(xin.begin(), xin.end(), x.begin()); 

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
  double binwidth = fs/N*3.1415*2; 
  cout << "The bin width is " << binwidth << endl; 
  return (double(pos)*binwidth);

}

double computeSqErr(ublas::vector<double> & x, sineParams s, double fs) {
  // takes in a sine parameter set s
  // computes the squared error between that sine parameter set 
  // and the input vector x
  
  int  N = x.size(); 
  double err = 0.0; 
  for(int i = 0; i < N; i++) {
    double t = (double)i/fs; 
    double diff =  (s.A*cos(t*s.w) + s.B * sin(t*s.w) + s.C) - x[i]; 
    err += diff * diff; 
  }
  
  return err; 
}


int main(void){ 

  int N(2<<14); 
  double noise(0.01); 

  ublas::vector<double> x(N); 
  double fs = 192000.0; 
  double w = 10000.0; 
  double A, B, C;
  A = 3.2; 
  B = 0.0; 
  C = 1.0; 
  for (int i = 0; i < N; i++){
    double t = i/fs; 
    x[i] = A*cos(t*w) + B * sin(t*w) + C 
      + noise* (double(rand())/RAND_MAX - 0.5); 
    
  }

  ifstream infile("nocap.1000hz.txt"); 
  for (int i = 0; i < N; i++) {
    infile >> x[i]; 
  }
  x = x / 32768.0; 
    
  cout << x[0] << ' ' << x[1] << endl; 

  sineParams q; 
  q.A = A; 
  q.B = B; 
  q.C = C; 
  q.w = w; 
  double sqerrstart = computeSqErr(x, q, fs); 

  cout << "The frequency is " << w << endl; 
 
  double detect = findPrimaryFrequency(x, fs); 
  cout << "We detected a frequency at " << detect << endl; 

    


  sineParams s; 
  s.A = 0.0; 
  s.B = 0.0; 
  s.C = 0.0; 
  s.w = detect; 

  cout << "A = " << s.A << " B = " << s.B << " C = " 
       << s.C << " w=" << s.w <<  endl; 

  s = threeParamFit(s, x, fs); 
  cout << "After 3-param fit" << endl;  cout << "A = " << s.A << " B = " << s.B << " C = " 
       << s.C << " w=" << s.w <<  endl; 


  s = fourParamFit(s, x, fs); 
  cout << " With four params fit: "<<endl;
  cout << "A = " << s.A << " B = " << s.B 
       << " C = " << s.C << " w = " << s.w << endl ;

  cout << "Now to calculate error" << endl; 

  double sqerr = computeSqErr(x, s, fs); 
  double rmsnoise = sqrt(sqerr / x.size()); 
  double rmssignal = sqrt(s.A*s.A + s.B*s.B)/sqrt(2.0);
  double thdn = 20*log(rmsnoise/rmssignal)/log(10.0); 
  
  cout <<  "The A delta is " << s.A - q.A << endl; 
  cout <<  "The B delta is " << s.B - q.B << endl; 
  cout <<  "The C delta is " << s.C - q.C << endl; 

  cout << " The error is "  << thdn << " dB" << endl;; 
  
}  
  
  
