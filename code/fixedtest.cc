#include <iostream>
#include <algorithm>
#include <iterator>
#include "fixed.h"
#include "filter.h"

using namespace std; 

bool test_basic()
{
  Fixed x = movepoint(1, 0); 
  Fixed y = movepoint(16, 4) ; 
  
  if (x == y) { 
    cout << "test 1 passed" << endl; 
  }
  
  x = movepoint(-1, 0); 
  y = movepoint(-16, 4); 
  
  if (x == y) { 
    cout << "test 2 passed" << endl; 
  }
    

}

bool test_trunc() 
{
  cout << "Beginning trunc() tests" << endl; 
  Fixed x = movepoint(0xF, 4); 
  Fixed y = movepoint(0xC, 4); 
  
  if (trunc(x, 2)  == y) { 
    cout << "test 1 passed" << endl; 
  } else { 
    cout << hex << trunc(x, 2) << " " << y << endl;
  }

}

bool test_overf()
{
  Fixed x = movepoint(0xF, 4);
  if (overf(x, 1) == movepoint(0xF, 4)) {
    cout << "test 1 passed" << endl;
  }
  
  x = movepoint(0x1, 0); 
  cout << hex << overf(x, 1) << endl; 
  x = movepoint(-1, 0); 
  cout << hex <<  x << endl; 
}

bool test_convrnd()
{
  cout << "testing convrnd()" << endl;
  Fixed x = movepoint(0x100, 8); 
  if (convrnd(x, 8) ==  movepoint(0x100, 8))
    cout << "test 1 passed" << endl; 
  
  x = movepoint(0xFF, 8); 
  if (convrnd(x, 8) == movepoint(0xFF, 8))
    cout << "test 2 passed" << endl; 
  
  
  // 0.10001001 rounds at 4 decimal points to 0.10010000
  x = movepoint(0x89, 8);
  if (convrnd(x, 4) == movepoint(0x90, 8))
    cout << "test 3 passed" << endl;
  cout << hex << x << ' ' << convrnd(x, 4) << endl; 
  
  // 0.10001000 rounds to 0.10000000 at 4 decimal points
  x = movepoint(0x88, 8); 
  if (convrnd(x, 4) == movepoint(0x80, 8))
    cout << "test 4 passed" << endl;
  cout << hex << x << ' ' << convrnd(x, 4) << endl; 
  
  // 0.10011000 rounds to 0.10100000 at 4 decimal points
  x = movepoint(0x98, 8); 
  if (convrnd(x, 4) == movepoint(0xA0, 8))
    cout << "test 5 passed" << endl;
  cout << hex << x << ' ' << convrnd(x, 4) << endl; 
  
  
}

int main()
{
  test_basic(); 
  test_trunc(); 
  test_overf(); 
  test_convrnd(); 

  std::cout << "Done" << std::endl; 

}

