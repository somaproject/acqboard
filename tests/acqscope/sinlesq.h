#ifndef SINLESQ_H
#define SINLESQ_H
#include <fftw3.h>
#include <iostream>
#include <vector>
#include <math.h>
#include <boost/numeric/ublas/matrix.hpp>
#include <boost/numeric/ublas/io.hpp>
#include <boost/numeric/ublas/expression_types.hpp>
#include <boost/numeric/ublas/exception.hpp>
#include <boost/numeric/ublas/traits.hpp>
#include <boost/numeric/ublas/functional.hpp>
#include <boost/numeric/ublas/matrix.hpp>
#include <boost/numeric/ublas/matrix_proxy.hpp>
#include <boost/numeric/ublas/io.hpp>

using namespace boost::numeric::ublas;

struct sineParams {
  double A; 
  double B;
  double C; 
  double w;
};

sineParams threeParamFit(sineParams init, 
			 boost::numeric::ublas::vector<double> &y, 
			 double fs);

sineParams fourParamFit(sineParams init, 
			boost::numeric::ublas::vector<double> &y, 
			double fs);

void normalize(boost::numeric::ublas::vector<double> x);
double findPrimaryFrequency(boost::numeric::ublas::vector<double> & xin, double fs);
double computeSqErr(boost::numeric::ublas::vector<double> & x, sineParams s, double fs); 
double computeTHDN(boost::numeric::ublas::vector<double> & x, double fs); 


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
      BOOST_UBLAS_CHECK (e1 () (best_row, n) != value_type (), singular ());

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

#endif
