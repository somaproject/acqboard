#include <Python.h>
#include <Numeric/arrayobject.h>
#include "sinlesq.h"
#include <iostream>


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
  int i, n, fs; 
  double thdn (0.0); 
  
  if (!PyArg_ParseTuple(args, "Oi", &input, &fs))
    return NULL; 
  
  array = (PyArrayObject *)
    PyArray_ContiguousFromObject(input, PyArray_DOUBLE, 1, 1);
  
  if (array == NULL)
    return NULL; 
  n = array->dimensions[0]; 

  sineParams s; 
  thdn = computeTHDNpy((double*)array->data, n, fs, &s); 
  
  
  Py_DECREF(array); 
  return  Py_BuildValue("(ddddd)", thdn, s.A, s.B, s.C, s.w);  
//#PyFloat_FromDouble(thdn); 

}


static PyObject * 
sinlesq_compute10kHzBLTHDN(PyObject *self, PyObject *args)
{
  PyObject *input; 
  PyArrayObject *array;
  int i, n, fs; 
  double thdn (0.0); 
  
  if (!PyArg_ParseTuple(args, "Oi", &input, &fs))
    return NULL; 
  
  array = (PyArrayObject *)
    PyArray_ContiguousFromObject(input, PyArray_DOUBLE, 1, 1);
  
  if (array == NULL)
    return NULL; 
  n = array->dimensions[0]; 
  
  thdn = compute10kHzBLTHDNpy((double*)array->data, n, fs); 

  Py_DECREF(array); 
  return PyFloat_FromDouble(thdn); 

}

static PyMethodDef SinlesqMethods[] = {
  {"test", sinlesq_test, METH_VARARGS, 
   "The test command"}, 
  {"computeTHDN", sinlesq_computeTHDN, METH_VARARGS, 
   "Compute THD+N"},
  {"compute10kHzBLTHDN", sinlesq_compute10kHzBLTHDN, METH_VARARGS,
   "Compute 10kHz bandlimited THD+N"},
  {NULL, NULL, 0, NULL}
}; 



PyMODINIT_FUNC
initsinlesq(void)
{
  (void) Py_InitModule("sinlesq", SinlesqMethods); 
  import_array(); 
}

