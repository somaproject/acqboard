#include "fixed.h"

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

Fixed operator+(const Fixed& rhs, const Fixed& lhs)
{
  // When you add two numbers of differing signs, the result
  // has a sign equal to the max of the signs of the first two, 
  // and we correctly align the decimal points
  
  if (rhs.base() < lhs.base() )
    {
      int p = lhs.base() - rhs.base(); 
      return Fixed(rhs.val() * (1 << p) + lhs.val(), lhs.base());
    } else if (lhs.base() < rhs.base()) 
      {
	int p = rhs.base() - lhs.base(); 
	return Fixed(lhs.val() * (1 << p) * rhs.val(), rhs.base()); 
      } else 
	{
	  return Fixed(lhs.val() + rhs.val(), rhs.base());
	}
}

Fixed operator*(const Fixed& rhs, const Fixed& lhs)
{
  return Fixed(rhs.val() * lhs.val(), rhs.base() + lhs.base())

}

std::ostream& operator<<(std::ostream& out, const Fixed& f)
{
  out << float(f.val()) / float(1 << (f.base()-1)); 
  return out; 
}
