

#include "thdn.h"
#include <fstream>
#include <istream>


THDN::THDN() :
  N_(1024),
  pos_ (0),
  recentTHDN_(0.0), 
  h_(1000)
{
  
  std::cout << "THDN constructor called" << std::endl; 
  data_.resize(N_); 

  std::ifstream hfile("10kHz_LPF.dat"); 
  
  int i = 0; 
  ublas::vector<double> invect(1000); 
  
  while (!hfile.eof()) {
    double hval; 
    hfile >> hval;
    h_[i] = hval;
    i++; 
  }
  
  h_.resize(i); 
  
  std::cout << h_; 
}


double THDN::getTHDN(void){ 
  return recentTHDN_; 
}

void THDN::add_data(short x){ 
  if (pos_ < N_ and pos_ >= 0) {
    data_[pos_] = x/32768.0;
  }
  pos_++; 

  if (pos_ == N_) {
    recentTHDN_  = computeBandLimitedTHDN(data_, h_, 192000.0); 
    //recentTHDN_  = computeTHDN(data_, 192000.0); 
    pos_ = -65536; 
    std::cout << "THe calculated thd+n is " << recentTHDN_ << "dB" 
	      << std::endl; 
  }

}
