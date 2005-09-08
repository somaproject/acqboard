

#include "thdn.h"

THDN::THDN() :
  N_(1024),
  pos_ (0),
  recentTHDN_(0.0)
{
  
  std::cout << "THDN constructor called" << std::endl; 
  data_.resize(N_); 
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
    recentTHDN_  = computeTHDN(data_, 192000); 
    pos_ = -65536; 
    std::cout << "THe calculated thd+n is " << recentTHDN_ << "dB" 
	      << std::endl; 
  }

}
