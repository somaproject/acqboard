#include "fixed.h"
#include <iomanip>
Fixed::Fixed(void) :
  val_(0),
  base_(0)
{
}

Fixed::Fixed(int base):
  val_(0),
  base_(base)
{
}


Fixed::Fixed(long long val, int base) :
  val_(val),
  base_(base)
{
}

long long Fixed::val(void) const
{
  return val_;
}

int Fixed::base(void) const
{
  return base_;
}

void Fixed::trunc(int bits) 
{
  if (bits < base_) {
    val_ = val_ / (pow2(base_-bits));
    base_ = bits;    
  } 
}

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

Fixed operator+(const Fixed& rhs, const Fixed& lhs)
{
  // When you add two numbers of differing signs, the result
  // has a sign equal to the max of the signs of the first two, 
  // and we correctly align the decimal points
  
  if (rhs.base() < lhs.base() )
    {
      int p = lhs.base() - rhs.base(); 
      return Fixed(rhs.val() * (1L << p) + lhs.val(), lhs.base());
    } else if (lhs.base() < rhs.base()) 
      {
	int p = rhs.base() - lhs.base(); 
	return Fixed(lhs.val() * (1L << p) * rhs.val(), rhs.base()); 
      } else 
	{
	  return Fixed(lhs.val() + rhs.val(), rhs.base());
	}
}

Fixed operator*(const Fixed& rhs, const Fixed& lhs)
{
  
  return Fixed(rhs.val() * lhs.val(), rhs.base() + lhs.base()-1);

}

std::ostream& operator<<(std::ostream& out, const Fixed& f)
{
  out << std::setprecision(10) << 
      std::setiosflags(std::ios::showpoint) <<  ((double)f.val()/ (double)(pow2(f.base()-1))); 
  return out; 
}
