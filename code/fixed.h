#ifndef FIXED_H
#define FIXED_H
#include <iostream>
#include <sstream>
#include <string>
#include <gmpxx.h>

typedef mpz_class Fixed;

inline Fixed pow2(int x); 

/*

This is my fixed-point class that hopefully works; everything is a long-long and we just use a series of functions. 
x
all numbers are 64-bit, with 34.30 format. 



*/

inline std::string hprint(Fixed x, int width, int bits);

#define POINTPOS 48

inline Fixed rshift(const Fixed x, int bits) {
  Fixed y; 
   
  mpz_fdiv_q_2exp(y.get_mpz_t(), x.get_mpz_t(), bits);  
  return y ;

}

inline Fixed lshift(const Fixed x, int bits) {
  Fixed y; 
   
  mpz_mul_2exp(y.get_mpz_t(), x.get_mpz_t(), bits);  
  return y ;

}

inline Fixed modulo(const Fixed x, const Fixed z) {
  Fixed y; 
  mpz_mod(y.get_mpz_t(), x.get_mpz_t(), z.get_mpz_t());
  return y;
}

inline Fixed movepoint(Fixed x, int bits) {
  // takes in a long long x and moves the binary point
  // bits -1 to the left. I.e. 
  // movepoint(0x7FFF, 16) should give 0.1111111111111111
  Fixed y = lshift(x, POINTPOS - bits); 
  return y; 
}



inline Fixed trunc(Fixed x, int bits) {
  // Truncate ; discard everything after the bits, so, 
  // a.b becomes a.(b-bits)
  
  Fixed r = rshift(x, POINTPOS - bits);
  return lshift(r, POINTPOS - bits); 
}

inline Fixed convrnd(Fixed x, int bits) {
  //
  // convergent rounding to a number with bits bits, i.e. 
  // we turn a.b number into an a.bits number. 

  if ( x > 0) {
    Fixed os = lshift(Fixed(1), POINTPOS - bits); 
    Fixed rem = modulo(x, os); 
    if (rem > rshift(os, 1)) {
      return x - rem + os; 
    }  else if (rem < rshift(os, 1)) {
      return x - rem; 
    } else { 
      // rem == rshift(os, 1)
      if (modulo(rshift(x, POINTPOS-bits), 2) == 0) {
	return x - rem;
      } else {
	return x - rem + os;
      }
    }
  } else {
    // negative 
    Fixed os = lshift(Fixed(1), POINTPOS - bits); 
    Fixed rem = modulo(x, os); 

    if (rem > rshift(os, 1)) {
      return x - rem + os; 
    }  else if (rem < rshift(os, 1)) {
      return x - rem; 
    } else { 
      // rem == rshift(os, 1)
      
      if (modulo(rshift(x, POINTPOS-bits), 2) == 0) {
	return x - rem;
      } else {
	return x - rem + os;
      }
    }
  } 
     
}

inline Fixed overf(Fixed x, int bits) {
  // overflow: if the number is greater to or less than 2^bits then we cap 
  // it. bits must be positive. 
  // for example: 
  // overf(1) leaves a single bit in the a.b form for a., i.e. 
  // turns it into a 1.b. 

  Fixed bitfact = 1; 
  bitfact = lshift(bitfact, POINTPOS + bits - 1);
  //std::cout << std::hex << bitfact << std::endl;
  if (x > (bitfact -1) ) {
    return bitfact -1; 
  } else { 
    if (x < -bitfact) {
      return -bitfact;
    }
    else {
      return x;
    }
  }  
}


inline long getint(Fixed x, int bits) {
  // returns an int where the LSBs are a.bits of the int
   mpz_class t(x >> (POINTPOS - bits));
   return t.get_si(); 
}

inline Fixed mult(Fixed x, Fixed y) {
  return rshift((x*y),  POINTPOS); 
}

inline std::string hprint(Fixed x, int width, int bits)
{
  /* Returns a hexadecimal printed string width chars 
     wide representing the value of the number. We
     assume that we want the lower points bits to be
     to the right of the decimal point.

  */

  Fixed y = rshift(x, POINTPOS - bits); 
  
  std::ostringstream s; 
  s.width(width); 
  s.setf(std::ios::uppercase); 
  if (x < 0) {
    s.fill('0');
    Fixed r(1); 
    r = lshift(r, width * 4);
    s << std::hex << r+y; 
  } else {
    s.fill('0');
    s << std::hex << y; 
  }
  
  
  return s.str();
  
}  
	 
#endif //FIXED_H
