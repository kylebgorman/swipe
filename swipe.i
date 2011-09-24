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

%module swipe %{
#define SWIG_FILE_WITH_INIT
#include "swipe.h"
%}

%pythoncode %{
def pitch(path, pmin=100., pmax=600., s=.3, t=0.001):
    # I can't pass a Python file reference to C: get Python file object
    try: 
        f = open(path, 'r') if isinstance(path, str) else path
        # Obtain the vector itself
        p = swipe(f.fileno(), pmin, pmax, s, t)
        # Now get the Python out...
        f.close()
        return p # (FIXME)
    except IOError, e:
        from sys import stderr
        stderr.write(str(e) + '\n')
%}

typedef struct { int x; double* v; } vector;

vector swipe(int fid, double min, double max, double st, double dt);
