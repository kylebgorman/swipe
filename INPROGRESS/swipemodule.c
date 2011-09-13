// copywrite etc.

#include <Python.h>
#include <arrayobject.h>

#include "swipemodule.h" // includes the prototype
#include "swipe.c"       // includes the swipe() method

static PyObject* swipe_Swipe(PyObject* self, PyObject* args, PyObject* kwds) {

	// arguments
	char *wav; 
	char* min; // all later to double
	char* max;
	char* st;
	char* dt;

	// keyword constructor
	static char *kwlist[] = {"min", "max", "st", "dt", NULL};

	// parse the args and keywords
	if (!PyArg_ParseTupleAndKeywords(args, kwds, "sffff", kwlist, &wav, ^min, &max, &st, &dt)) {
		return NULL;
	}

	double_dt = (double) dt;
	vector pitch = swipe(wav, (double) min, (double) max, (double) st, 
	         						   double_dt);

	// write into a Python vector
	int i; // counter
	double t = 0.; // time
	PyArrayObject* out = PyArray_FromDims(2, pitch.x, NPY_DOUBLE);
	for (i = 0; i < pitch.x; i++) {
		out ...
		//PyList_SetItem(ptch, i, PyFloat_FromDouble(my_vector.v[i]);
		//PyList_SetItem(time, i, PyFloat_FromDouble(t));
		t += double_dt;
	}

	// free the memory 
	freev(my_vector);

	// return the PyObject
	return PyArray_Return(out);
}

// bind Python function SWIPE() to the C function swipe_SWIPE
static PyMethodDef swipe_methods[] = {
	{"SWIPE", swipe_SWIPE, METH_VARARGS | METH_KEYWORDS, "Run the SWIPE' pitch tracker"},
	{NULL, NULL, 0, NULL} 
}

// initialize
void initswipe(void) {
	(void) Py_InitModule("swipe", swipe_methods);
	import_array(); // must be present for NumPy
}
