#include <iostream>
#include <algorithm>
#include <iterator>
#include "fixed.h"
#include "filter.h"

using namespace std; 

bool test_convrnd()
{
  // 0.111 should round to 0.11
  Fixed x(7, 4); 
  x.convrnd(3);
  if(x.val() == 4 and x.base() == 3){
    cout << "test 1 passed" << endl;
  } else {
    cout << "test 1 failed" << endl; 
  }
  
  
}

int main()
{

  test_convrnd(); 
  std::cout << "Hello World" << pow2(38) << endl; 
  Fixed f(1,2); 
  Fixed g(-1, 2); 
  std::cout << f << endl; 
  
  
  Fixed a(32767, 16);
  Fixed b((1L << 21)-1, 22); 
  Fixed c = a * b; 
  cout << a << ' ' << b << ' '<< c << endl; 
  cout << c.base() << ' '<< c.val() <<endl;

  signal x(4), h(3); 
  x[0] = Fixed(32767, 16); 
  x[1] = Fixed(32768/2, 16); 
  x[2] = Fixed(32768/4, 16); 
  x[3] = Fixed(32768/5, 16); 
  std::copy(x.begin(), x.end(), ostream_iterator<Fixed>(std::cout, " ")); 
  std::cout << std::endl; 
  h[0] = Fixed((1 << 21)-1, 22); 
  h[1] = Fixed(22); 
  h[2] = Fixed(22); 
  std::copy(h.begin(), h.end(), ostream_iterator<Fixed>(std::cout, " ")); 
  std::cout << std::endl; 

  std::cout << x[0] * h[0] << std::endl; 

  std::cout << x[0] <<std::endl; 
  signal y =  rmac(x, h, 24);
 
  std::cout << std::endl;
  std::copy(y.begin(), y.end(), ostream_iterator<Fixed>(std::cout, " ")); 

  std::cout << std::endl; 
  signal rndy = convrnd(y, 3); 
  std::copy(rndy.begin(), rndy.end(), ostream_iterator<Fixed>(std::cout, " ")); 
  std::cout << std::endl; 
  signal ovfy = overf(rndy, 1);
  cout <<  rndy[0].val() << ' ' << rndy[0].base() << endl; 
  cout << ovfy[0].val()  << ' ' <<  ovfy[0].base() << endl; 
  std::copy(ovfy.begin(), ovfy.end(), ostream_iterator<Fixed>(std::cout, " ")); 
  std::cout << "Done" << std::endl; 

}

