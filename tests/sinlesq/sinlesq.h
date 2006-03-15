#ifndef SINLESQ_H
#define SINLESQ_H
#include <fftw3.h>
#include <iostream>
#include <vector>
#include <math.h>
#include <boost/numeric/ublas/matrix.hpp>
#include <boost/numeric/ublas/io.hpp>
#include <boost/numeric/ublas/exception.hpp>
#include <boost/numeric/ublas/traits.hpp>
#include <boost/numeric/ublas/functional.hpp>
#include <boost/numeric/ublas/matrix.hpp>
#include <boost/numeric/ublas/matrix_proxy.hpp>
#include <boost/numeric/ublas/lu.hpp>

using namespace boost::numeric::ublas;

struct sineParams {
  double A; 
  double B;
  double C; 
  double w;
};

char const * greet();

double computeTHDNpy(double* x, int N, int fs, sineParams *); 
double compute10kHzBLTHDNpy(double* x, int N, int fs); 

double compute10kHzBandLimitedTHDN(boost::numeric::ublas::vector<double> & x, 
				 double fs);

sineParams threeParamFit(sineParams init, 
			 boost::numeric::ublas::vector<double> &y, 
			 double fs);

sineParams fourParamFit(sineParams init, 
			boost::numeric::ublas::vector<double> &y, 
			double fs);

void normalize(boost::numeric::ublas::vector<double> x);
double findPrimaryFrequency(boost::numeric::ublas::vector<double> & xin, double fs);
double computeSqErr(boost::numeric::ublas::vector<double> & x, sineParams s, double fs); 
double computeTHDN(boost::numeric::ublas::vector<double> &, double, sineParams * = 0); 

double computeBandLimitedTHDN(boost::numeric::ublas::vector<double> &, 
			      const boost::numeric::ublas::vector<double> &,
			      double); 

void filter(boost::numeric::ublas::vector<double> & x,
	    const boost::numeric::ublas::vector<double> & h, 
	    boost::numeric::ublas::vector<double>* y); 

template<class E1, class E2> void inverse (matrix_expression<E1> &e1, matrix_expression<E2> &e2) {
  
  typedef typename E2::size_type size_type;
  typedef typename E2::difference_type difference_type;
  typedef typename E2::value_type value_type;

   BOOST_UBLAS_CHECK (e1 ().size1 () == e2 ().size1 (), bad_size ());
   BOOST_UBLAS_CHECK (e1 ().size2 () == e2 ().size2 (), bad_size ());
   size_type size = e1 ().size1 ();
   for (size_type n = 0; n < size; ++ n) {
      // processing column n
      // find the row that has the largest number at this column (in absolute value)
      size_type best_row = index_norm_inf(row(e1(), n));

      // check wether this number is'nt zero
      //std::cout << "e1bestrow=" << e1 () (best_row, n)  << std::endl;
      //std::cout << "valuetype=" << value_type()  << std::endl;
      //BOOST_UBLAS_CHECK (e1 () (best_row, n) != value_type (), singular ());

      { // swap this row with the n-th row
         vector<value_type> temp = row(e1(), best_row);
         row(e1(), n) = row(e1(), best_row);
         row(e1(), best_row) = temp;
      }
      // do the same on the destination matrix
      { // swap this row with the n-th row
         vector<value_type> temp = row(e2(), best_row);
         row(e2(), n) = row(e2(), best_row);
         row(e2(), best_row) = temp;
      }

      // now eliminate all elements below and above this row
      for (size_type i = 0; i < size; ++ i)
         if (i!=n) {
            value_type t = -e1 () (i, n)/ e1 () (n, n);
            row(e1(), i) += t*row(e1(), n);
            row(e2(), i) += t*row(e2(), n);
         } else {
            value_type t = 1 / e1 () (i, n);
            row(e1(), i) *= t;
            row(e2(), i) *= t;
         }
   }

}

 /* Matrix inversion routine.
    Uses lu_factorize and lu_substitute in uBLAS to invert a matrix */
 template<class T>
 void InvertMatrix (const matrix<T>& input, matrix<T>& inverse) {

 	// create a working copy of the input
 	matrix<T> A(input);
 	// perform LU-factorization
 	lu_factorize(A);

 	// create identity matrix of "inverse"
 	inverse.clear();
 	for (unsigned int i = 0; i < A.size1(); i++)
 		inverse(i,i) = 1;

 	// backsubstitute to get the inverse
 	lu_substitute<const matrix<T>, matrix<T> >(A, inverse);
 }


template<class T>
 //#define T double /// for debug
 boost::numeric::ublas::matrix<T>
 gjinverse(const boost::numeric::ublas::matrix<T> &m, 
           bool &singular)
 {
     using namespace boost::numeric::ublas;

     const int size = m.size1();

     // Cannot invert if non-square matrix or 0x0 matrix.
     // Report it as singular in these cases, and return 
     // a 0x0 matrix.
     if (size != m.size2() || size == 0)
     {
         singular = true;
         matrix<T> A(0,0);
         return A;
     }

     // Handle 1x1 matrix edge case as general purpose 
     // inverter below requires 2x2 to function properly.
     if (size == 1)
     {
         matrix<T> A(1, 1);
         if (m(0,0) == 0.0)
         {
             singular = true;
             return A;
         }
         singular = false;
         A(0,0) = 1/m(0,0);
         return A;
     }

     // Create an augmented matrix A to invert. Assign the
     // matrix to be inverted to the left hand side and an
     // identity matrix to the right hand side.
     matrix<T> A(size, 2*size);
     matrix_range<matrix<T> > Aleft(A, 
                                    range(0, size), 
                                    range(0, size));
     Aleft = m;
     matrix_range<matrix<T> > Aright(A, 
                                     range(0, size), 
                                     range(size, 2*size));
     Aright = identity_matrix<T>(size);

     // Swap rows to eliminate zero diagonal elements.
     for (int k = 0; k < size; k++)
     {
         if ( A(k,k) == 0 ) // XXX: test for "small" instead
         {
             // Find a row(l) to swap with row(k)
             int l = -1;
             for (int i = k+1; i < size; i++) 
             {
                 if ( A(i,k) != 0 )
                 {
                     l = i; 
                     break;
                 }
             }

             // Swap the rows if found
             if ( l < 0 ) 
             {
                 std::cerr << "Error:" <<  __FUNCTION__ << ":"
                           << "Input matrix is singular, because cannot find"
                           << " a row to swap while eliminating zero-diagonal.";
                 singular = true;
                 return Aleft;
             }
             else 
             {
                 matrix_row<matrix<T> > rowk(A, k);
                 matrix_row<matrix<T> > rowl(A, l);
                 rowk.swap(rowl);

 #if defined(DEBUG) || !defined(NDEBUG)
                 std::cerr << __FUNCTION__ << ":"
                           << "Swapped row " << k << " with row " << l 
                           << ":" << A << "\n";
 #endif
             }
         }
     }

     // Doing partial pivot
     for (int k = 0; k < size; k++)
     {
         // normalize the current row
         for (int j = k+1; j < 2*size; j++)
             A(k,j) /= A(k,k);
         A(k,k) = 1;

         // normalize other rows
         for (int i = 0; i < size; i++)
         {
             if ( i != k )  // other rows  // FIX: PROBLEM HERE
             {
                 if ( A(i,k) != 0 )
                 {
                     for (int j = k+1; j < 2*size; j++)
                         A(i,j) -= A(k,j) * A(i,k);
                     A(i,k) = 0;
                 }
             }
         }

 #if defined(DEBUG) || !defined(NDEBUG)
         std::cerr << __FUNCTION__ << ":"
                   << "GJ row " << k << " : " << A << "\n";
 #endif
     }

     singular = false;
     return Aright;
 }

#endif
