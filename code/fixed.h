#ifndef FIXED_H
#define FIXED_H
#include <iostream>

inline long long pow2(int x); 

class Fixed {


 public:
  Fixed(void) :
    val_(0),
    base_(0)
    {
    }
  
  Fixed(int base):
    val_(0),
    base_(base)
    {
    }
  

  Fixed(long long val, int base) :
    val_(val),
    base_(base)
    {
    }

  
  friend std::ostream& operator<< (std::ostream&, const Fixed&); 
  
  void convrnd(int point); 
  void overf(int a);

  inline long long val(void) const
    {
      return val_;
    }
  
  inline int base(void) const
    {
      return base_;
    }
  
  inline void trunc(int bits) 
    {
      if (bits < base_) {
	val_ = val_ / (pow2(base_-bits));
	base_ = bits;    
      } 
    }
  

 private:
  long long val_; 
  int base_; 
  
};

inline Fixed operator+(const Fixed& rhs, const Fixed& lhs)
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

inline Fixed operator*(const Fixed& rhs, const Fixed& lhs)
{
  return Fixed(rhs.val() * lhs.val(), rhs.base() + lhs.base()-1);
}

inline long long pow2(int x) {
  long long r(2); 
 
  for (int i = 0; i < (x - 1); i++){
    r = r *  2; 
  }
  return r; 
}
	 
#endif //FIXED_H
