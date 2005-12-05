#ifndef THDN_H
#define THDN_H
#include <boost/numeric/ublas/matrix.hpp>
#include <boost/numeric/ublas/io.hpp>
#include "sinlesq.h"

namespace ublas = boost::numeric::ublas;


class THDN
{
  // a simple class that maintains an internal buffer and lets you compute
  // the THD+N

 public:
  THDN();
  
  void add_data(short x);
  double getTHDN(void); 
  
  
 private:
  ublas::vector<double> data_; 
  ublas::vector<double> h_; 
  int N_; 
  int pos_; 
  double recentTHDN_; 
  double average_; 
  double count_; 
  
}; 


#endif // THDN_H
