#include "fixed.h"
#include <iomanip>


void Fixed::overf(int a)
{
  // simply determines if it is biger than a fixed
  // point number with a bits to the left of the point. 
  a--;
  if (val_ >= (pow2(a+base_ -1))) {
    val_ = pow2(a + base_ -1) - 1;
  } else if ( val_ < - (pow2(a + base_ -1 )))
    {
      val_ = - (pow2(a + base_ -1 )); 
    }
  
}
void Fixed::convrnd(int point)
{
  long long pow = pow2(base_ - point);
  long long q = val_ % pow; 

  if (q > (pow / 2)) 
    {
      val_ = val_/pow + 1;
      base_ = point; 
    } else if (q < (pow / 2) )
      {
	val_ = val_/pow;
	base_ = point;
      } else {
	if (( (val_ / pow) % 2) == 0 ) 
	  { // even
	    val_ = val_ / pow;
	    base_ = point;
	  } else {
	    val_ = val_ / pow + 1; 
	    base_ = point;
	  }
      }
  
}


std::ostream& operator<<(std::ostream& out, const Fixed& f)
{
  out << std::setprecision(10) << 
      std::setiosflags(std::ios::showpoint) <<  ((double)f.val()/ (double)(pow2(f.base()-1))); 
  return out; 
}
