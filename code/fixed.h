#ifndef FIXED_H
#define FIXED_H
#include <iostream>

typedef long long Fixed;

inline Fixed pow2(int x); 

/*

This is my fixed-point class that hopefully works; everything is a long-long and we just use a series of functions. 

all numbers are 64-bit, with 16.48 format. 



*/

#define POINTPOS 48

inline Fixed movepoint(long long x, int bits) {
  // takes in a number x and assumes it is of the form a.bits
  // and thus aligns it
  Fixed y = x << (POINTPOS - bits); 
  return y; 
}

inline Fixed convrnd(Fixed x, int bits) {
  //
  // convergent rounding to a number with bits bits, i.e. 
  // we turn a.b number into an a.bits number 
  
  Fixed os = 1; 
  os = os << (POINTPOS-bits); 

  Fixed div = x / (os);
  Fixed rem = x % (os); 
  
  if (rem < (os >> 1)) { 
    return x - rem; 
  } else if (rem > (os >> 1)) { 
    return x - rem + os; 
  } else {
    if (div % 2 == 0) { 
      // even, round down
      return x - rem;
    } else {
      return x - rem + os;
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
  bitfact = bitfact << (POINTPOS + bits - 1);
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

inline Fixed trunc(Fixed x, int bits) {
  // Truncate ; discard everything after the bits, so, 
  // a.b becomes a.(b-bits)
  
  Fixed r = x >> (POINTPOS - bits);
  return (r << (POINTPOS - bits)); 
  
  
}

inline int getint(Fixed x, int bits) {
  // returns an int where the LSBs are a.bits of the int
  return int(x >> (POINTPOS - bits));
}
	 
#endif //FIXED_H
