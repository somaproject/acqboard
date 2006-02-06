#include <boost/python.hpp>

using namespace boost::python; 

BOOST_PYTHON_MODULE(sinlesq)
{
  def("greet", greet);

}
