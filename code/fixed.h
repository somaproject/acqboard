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

 private:
  long long val_; 
  int base_; 
  
};

Fixed operator+ (const Fixed& rhs, const Fixed& rhs); 
Fixed operator* (const Fixed& rhs, const Fixed& lhs); 


#endif
