#ifndef FIXED_H
#define FIXED_H
#include <iostream>

class Fixed {

 public:
  Fixed(void); 
  Fixed(int base); 
  Fixed(long long val, int base);
  
  long long val(void) const;
  int base(void) const;  
  friend std::ostream& operator<< (std::ostream&, const Fixed&); 
  void trunc(int bits); 
  void convrnd(int point); 
  void overf(int a);
 private:
  long long val_; 
  int base_; 
  
};

Fixed operator+ (const Fixed& rhs, const Fixed& rhs); 
Fixed operator* (const Fixed& rhs, const Fixed& lhs); 

inline long long pow2(int x) {
  long long r(2); 
 
  for (int i = 0; i < (x - 1); i++){
    r = r *  2; 
  }
  return r; 
}
	 
#endif
