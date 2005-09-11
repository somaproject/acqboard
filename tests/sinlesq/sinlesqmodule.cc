#include <Python.h>
#include <Numeric/arrayobject.h>
#include "sinlesq.h"

static PyObject *
sinlesq_test(PyObject *self, PyObject *args)
{

  char *command;
  int sts; 
  
  if (!PyArg_ParseTuple(args, "s", &command))
    return NULL; 
  
  return Py_BuildValue("d", sts); 

}

static PyObject * 
sinlesq_computeTHDN(PyObject *self, PyObject *args)
{
  PyObject *input; 
  PyArrayObject *array;
  int i, n; 
  double thdn; 
  
  array = (PyArrayObject *)
    PyArray_ContiguousFromObject(input, PyArray_DOUBLE, 1, 1);

  n = array->dimensions[0]; 
  
  thdn = computeTHDNpy((double*)array->data, n, 192000); 

  Py_DECREF(array); 
  return PyFloat_FromDouble(thdn); 

}


static PyMethodDef SinlesqMethods[] = {
  {"test", sinlesq_test, METH_VARARGS, 
   "The test command"}, 
  {"computeTHDN", sinlesq_computeTHDN, METH_VARARGS, 
   "Compute THD+N"}, 
  {NULL, NULL, 0, NULL}
}; 



PyMODINIT_FUNC
initsinlesq(void)
{
  (void) Py_InitModule("sinlesq", SinlesqMethods); 
}

