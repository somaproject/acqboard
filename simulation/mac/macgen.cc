#include "../../code/fixed.h"
#include <iostream>
#include <fstream>
#include <boost/format.hpp>
#include <stdio.h>

using namespace std; 


void multgen(void)
{
  ofstream fdata("multiply.dat"); 
  
  int precision(26); 
  // tests:
  
  Fixed z = movepoint(0, 10); 

  // zeros:
  fdata << hprint(z, 8, 15) <<  ' '  
	<< hprint(z, 8, 15) << ' ' 
	<< hprint(mult(z, z), 8, precision -1) << endl;   
  
  Fixed x = movepoint(0x7FFF, 15);
  Fixed y = movepoint(0x1FFFFF, 21); 
  // max, min positive, negative values
  fdata << boost::format("%08X %08X %08X") % 
    getint(x, 15)  % getint(y, 21) % getint(mult(x, y), precision-1) << endl; 

  x = movepoint(-32768, 15);
  y = movepoint(-2097152, 21); 
  // max, min positive, negative values
  fdata << boost::format("%08X %08X %08X") % 
    getint(x, 15)  % getint(y, 21) % getint(mult(x, y), precision-1) << endl; 


  // a random set of values
  gmp_randclass r(gmp_randinit_default); 
  for (int i = 0; i < 1000; i++) 
    {
      x  = r.get_z_range(1<<26) << (48-26);
      y = r.get_z_range(1<<26) << (48 -26); 
      
      if(r.get_z_range(2) <1) 
	x = - x;
      if(r.get_z_range(2) <1) 
	y = - y;
      
      Fixed result = mult(trunc(x, 15), trunc(y, 21)); 
      
      fdata << hprint(trunc(x, 15), 8, 15) << ' ' 
	    << hprint(trunc(y, 21), 8, 21) << ' ' 
	    << hprint(result, 8, 25) << endl; 
    }
}


void accgen(void)
{
  ofstream fdata("accumulate.dat"); 


  // simple sum of 1s

  Fixed x = movepoint(0x7FFF, 15); 
  Fixed sum = movepoint(0, 10); 
  for (int i = 0; i < 126; i++) {     
    fdata << hprint(x, 12, 15) << ' '; 
    sum += x;
  }
  fdata << hprint(sum, 12, 15) << endl; 
  

  // negative 1s 
  x = movepoint(-0x8000, 15); 
  sum = movepoint(0, 10); 
  for (int i = 0; i < 126; i++) {     
    fdata << hprint(x, 12, 15) << ' ';
    sum += x;
  }

  fdata << hprint(sum, 12, 15) << endl;
  
  gmp_randclass r(gmp_randinit_default); 
  for (int i = 0; i < 1000; i++) { 
    sum = movepoint(0, 10); 
    for (int j = 0; j < r.get_z_range(127); j++) 
      {
	x  = r.get_z_range(1<<26) << (48-26);
	if(r.get_z_range(2) <1) 
	  x = - x; 
	fdata << hprint(x, 12, 15) << ' '; 
	sum += trunc(x, 15); 
      }
    fdata << hprint(sum, 12, 15) << endl;
  }





}

void convgen(void)
{
  ofstream fdata("convrnd.dat"); 
  
  Fixed x = movepoint(0x7FFF, 15);
  fdata << hprint(x, 12, 25) << ' ' << hprint(convrnd(x, 15), 12, 15) << endl; 

  x = movepoint(0x7FFFF, 19);
  fdata << hprint(x, 12, 25) << ' ' << hprint(convrnd(x, 15), 12, 15) << endl; 

  x = movepoint(-0x7FFFF, 19);
  fdata << hprint(x, 12, 25) << ' ' << hprint(convrnd(x, 15), 12, 15) << endl; 
  
  // edge cases
  x = movepoint(0x10007, 19);
  fdata << hprint(x, 12, 25) << ' ' << hprint(convrnd(x, 15), 12, 15) << endl; 

  x = movepoint(0x10008, 19);
  fdata << hprint(x, 12, 25) << ' ' << hprint(convrnd(x, 15), 12, 15) << endl; 

  x = movepoint(0x10009, 19);
  fdata << hprint(x, 12, 25) << ' ' << hprint(convrnd(x, 15), 12, 15) << endl; 

  x = movepoint(0x10017, 19);
  fdata << hprint(x, 12, 25) << ' ' << hprint(convrnd(x, 15), 12, 15) << endl; 

  x = movepoint(0x10018, 19);
  fdata << hprint(x, 12, 25) << ' ' << hprint(convrnd(x, 15), 12, 15) << endl; 

  x = movepoint(0x10019, 19);
  fdata << hprint(x, 12, 25) << ' ' << hprint(convrnd(x, 15), 12, 15) << endl; 

  // edge cases
  x = movepoint(-0x10007, 19);
  fdata << hprint(x, 12, 25) << ' ' << hprint(convrnd(x, 15), 12, 15) << endl; 

  x = movepoint(-0x10008, 19);
  fdata << hprint(x, 12, 25) << ' ' << hprint(convrnd(x, 15), 12, 15) << endl; 

  x = movepoint(-0x10009, 19);
  fdata << hprint(x, 12, 25) << ' ' << hprint(convrnd(x, 15), 12, 15) << endl; 

  x = movepoint(-0x10017, 19);
  fdata << hprint(x, 12, 25) << ' ' << hprint(convrnd(x, 15), 12, 15) << endl; 

  x = movepoint(-0x10018, 19);
  fdata << hprint(x, 12, 25) << ' ' << hprint(convrnd(x, 15), 12, 15) << endl; 

  x = movepoint(-0x10019, 19);
  fdata << hprint(x, 12, 25) << ' ' << hprint(convrnd(x, 15), 12, 15) << endl; 


  // and now, real randomness
  
  gmp_randclass r(gmp_randinit_default); 
  for (int i = 0; i < 1000; i++) { 
    
    x  = r.get_z_range(1<<26) << (48-26);
    fdata << hprint(x, 12, 25) << ' ' << hprint(convrnd(x, 15), 12, 15)  << ' '
	  << x << ' ' << convrnd(x, 15) << endl; 
  }

    for (int i = 0; i < 1000; i++) { 
    
    x  = (-r.get_z_range(1<<26)) << (48-26);
    fdata << hprint(x, 12, 25) << ' ' << hprint(convrnd(x, 15), 12, 15) << ' ' 
      << x << ' ' << convrnd(x, 15) << endl;  
  }



}


void overfgen(void)
{
  ofstream fdata("overflow.dat"); 
  
  Fixed x = movepoint(0x7FFF, 15);
  fdata << hprint(x, 12, 15) << ' ' << hprint(overf(x, 1), 12, 15) << endl; 

  x = movepoint(0x8000, 15);
  fdata << hprint(x, 12, 15) << ' ' << hprint(overf(x, 1), 12, 15) << endl; 

  x = movepoint(-0x8000, 15);
  fdata << hprint(x, 12, 15) << ' ' << hprint(overf(x, 1), 12, 15) << endl; 

  x = movepoint(-0x8001, 15);
  fdata << hprint(x, 12, 15) << ' ' << hprint(overf(x, 1), 12, 15) << endl; 



  // and now, real randomness
  
  gmp_randclass r(gmp_randinit_default); 
  for (int i = 0; i < 10000; i++) { 
    x  = r.get_z_range(1<<27) << (48-26);
    fdata << hprint(x, 12, 15) << ' ' << hprint(overf(x, 1), 12, 15) << endl; 
  }
  
  for (int i = 0; i < 10000; i++) { 
    x  = (-r.get_z_range(1<<27)) << (48-26);
    fdata << hprint(x, 12, 15) << ' ' << hprint(overf(x, 1), 12, 15) << endl;   }



}
 
int main(void)
{
  multgen(); 
  accgen();
  convgen(); 
  overfgen(); 
}
