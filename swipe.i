/* Copyright (c) 2009-2011 Kyle Gorman
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to 
 * deal in the Software without restriction, including without limitation the 
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or 
 * sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 *
 * swipe.i: SWIG file for python module
 */

%include "carrays.i"
%array_functions(double, doublea);

%module swipe %{
#define SWIG_FILE_WITH_INIT
#include "swipe.h"
%}

%pythoncode %{
def pitch(path, pmin=100., pmax=600., s=.3, t=0.001, show_nan=False):
    """
    Attempts to read a wav file from path (which is either a file object or a 
    string path to the file, and returns a list of [(time, value)] pairs.
    """
    try: 
        # Get Python path, just in case someone passed a file object
        #FIXME f = open(path, 'r') if isinstance(path, str) else path
        f = path if isinstance(path, str) else path.name
        # Obtain the vector itself
        P = pyswipe(f, pmin, pmax, s, t)
        # get the length and allocate
        tt = 0.
        results = [] 
        if show_nan:
            for i in range(P.x):
                results.append((tt, doublea_getitem(P.v, i)))
                tt += t
        else:
            from math import isnan
            for i in range(P.x):
                val = doublea_getitem(P.v, i)
                if not isnan(val):
                    results.append((tt, doublea_getitem(P.v, i)))
                tt += t
        return results

    except IOError, e:
        from sys import stderr
        stderr.write(str(e) + '\n')
        return
%}

typedef struct { int x; double* v; } vector;
vector pyswipe(char wav[], double min, double max, double st, double dt);
