#include <iostream>
#include <algorithm>
#include <iterator>
#include "fixed.h"
#include "filter.h"
#include <boost/test/unit_test.hpp>

using namespace std; 
using boost::unit_test_framework::test_suite;


void test_basic()
{
  Fixed x = movepoint(1, 0); 
  Fixed y = movepoint(16, 4) ; 
  
  BOOST_CHECK_EQUAL(x,  y);
  
  x = movepoint(-1, 0); 
  y = movepoint(-16, 4); 
  
  BOOST_CHECK_EQUAL(x, y);    

}

void test_trunc() 
{
  BOOST_CHECKPOINT("Testing Truncation");
  Fixed x = movepoint(0xF, 4); 
  Fixed y = movepoint(0xC, 4); 
  
  BOOST_CHECK_EQUAL (trunc(x, 2),  y);


}

void test_overf()
{
  Fixed x = movepoint(0xF, 4);
  BOOST_CHECK_EQUAL(overf(x, 1), movepoint(0xF, 4) );
  
  x = movepoint(-0x8001, 15); 
  BOOST_CHECK_EQUAL(overf(x, 1), movepoint(-0x8000, 15)); 
}

void test_convrnd()
{
  Fixed x = movepoint(0x100, 8); 
  BOOST_CHECK_EQUAL (convrnd(x, 8),  movepoint(0x100, 8));
  
  x = movepoint(0xFF, 8); 
  BOOST_CHECK_EQUAL (convrnd(x, 8),  movepoint(0xFF, 8));   
  
  // 0.10001001 rounds at 4 decimal points to 0.10010000
  x = movepoint(0x89, 8);
  BOOST_CHECK_EQUAL (convrnd(x, 4),  movepoint(0x90, 8)); 
  
  // 0.10001000 rounds to 0.10000000 at 4 decimal points
  x = movepoint(0x88, 8); 
  BOOST_CHECK_EQUAL (convrnd(x, 4),  movepoint(0x80, 8)); 
  
  // 0.10011000 rounds to 0.10100000 at 4 decimal points
  x = movepoint(0x98, 8); 
  BOOST_CHECK_EQUAL (convrnd(x, 4),  movepoint(0xA0, 8));


  // now negatives; if the 
  x = movepoint(-127, 8);

  BOOST_CHECK_EQUAL (convrnd(x, 0), movepoint(0,0)) ;
  
  x = movepoint(-128, 8);
  BOOST_CHECK_EQUAL(convrnd(x,0), movepoint(0, 0));
  
  x = movepoint(-129, 8);
  BOOST_CHECK_EQUAL(convrnd(x, 0), movepoint(-1, 0));
  
  x= movepoint(-128-256, 8); 
  BOOST_CHECK_EQUAL(convrnd(x, 0),  movepoint(-2,0));

  x= movepoint(-128-255, 8); 
  BOOST_CHECK_EQUAL(convrnd(x, 0),  movepoint(-1,0));

  x= movepoint(-12152320, 25); 
  BOOST_CHECK_EQUAL(convrnd(x, 15), movepoint(-11868, 15)); 
  cout << hprint(convrnd(x, 15), 10, 15) << endl; 

  Fixed a("-101941044576256"); 
  Fixed b("-101936753803264"); 
  cout << hprint(convrnd(a, 15), 10, 15) << endl; 

}


void test_getint()
{
  cout << "Testing getint()" << endl; 

  if (getint(movepoint(0x7FFF, 16), 16) == 0x7FFF) 
    cout << "test 1 passed" <<  movepoint(0x7FFF, 16) << endl;
  else 
    cout << getint(movepoint(0x7FFF, 16), 16) << endl;
}

void test_mult()
{
  Fixed x = movepoint(0x10, 4); 
  Fixed y = movepoint(0x10, 4); 
  
  BOOST_CHECK_EQUAL(mult(x,y), movepoint(0x10, 4));

  x = movepoint(-23962, 15); 
  y = movepoint(1930358, 21); 
  

}



void test_string()
{
  Fixed x = movepoint(0x7FFF, 15); 
  BOOST_CHECK_EQUAL(hprint(x, 4, 15), "7FFF"); 

  x = movepoint(-0x8000, 15); 
  BOOST_CHECK_EQUAL(hprint(x, 4, 15), "8000"); 

  x += movepoint(0x1, 15); 
  BOOST_CHECK_EQUAL(hprint(x, 4, 15), "8001"); 

  x = movepoint(-1, 15); 
  BOOST_CHECK_EQUAL(hprint(x, 4, 15), "FFFF"); 

  x = movepoint(7, 3);
  BOOST_CHECK_EQUAL(hprint(x, 4, 3), "0007");

  x = movepoint(-7, 3);
  BOOST_CHECK_EQUAL(hprint(x, 3, 3), "FF9"); 

  x = movepoint(-0x8001, 15);
  BOOST_CHECK_EQUAL(hprint(x, 5, 15),  "F7FFF"); 
  
  x = movepoint(-11868, 15);
  BOOST_CHECK_EQUAL(hprint(x, 6, 15),  "FFD1A4"); 

  Fixed y("-101941044576256"); 
  Fixed z("-101936753803264"); 
  BOOST_CHECK_EQUAL(hprint(z, 6, 15), "FFD1A5"); 


  
}

test_suite*
init_unit_test_suite( int argc, char * argv[] ) {
    test_suite* test= BOOST_TEST_SUITE( "Basic Test" );

    test->add( BOOST_TEST_CASE( &test_basic) );
    test->add( BOOST_TEST_CASE( &test_trunc) ); 
    test->add( BOOST_TEST_CASE( &test_overf) ); 
    test->add( BOOST_TEST_CASE( &test_mult) ); 
    test->add( BOOST_TEST_CASE( &test_convrnd) ); 
    test->add( BOOST_TEST_CASE( &test_string) ); 
    return test; 
}



int 
test_main( int /*argc*/, char* /*argv*/[] ) 
{
    return 0;
}

