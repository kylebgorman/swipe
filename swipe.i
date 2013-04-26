/* Copyright (c) 2009-2013 Kyle Gorman
 *
 * Permission is hereby granted, free of charge, to any person obtaining a 
 * copy of this software and associated documentation files (the 
 * "Software"), to deal in the Software without restriction, including 
 * without limitation the rights to use, copy, modify, merge, publish, 
 * distribute, sublicense, and/or sell copies of the Software, and to 
 * permit persons to whom the Software is furnished to do so, subject to 
 * the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included 
 * in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * 
 * swipe.i: SWIG file for Python module
 * Kyle Gorman
 */

%include "carrays.i"
%array_functions(double, doublea);

%module swipe %{
#define SWIG_FILE_WITH_INIT
#include "swipe.h"
%}

typedef struct {
    int x; 
    double* v; } vector;

vector pyswipe(char[], double, double, double, double);

%pythoncode %{
import numpy as NP

from bisect import bisect
from os import access, R_OK
from math import log, fsum, isnan, sqrt

## helper functions

def _mean(x):
    """ 
    Compute mean. Seems to be much faster than using Numpy
    """
    if not len(x):
        return float('nan')
    return fsum(x) / len(x)


def _median(x):
    return NP.median(x)


def _regress(x, y):
    """
    Compute the intercept and slope for y ~ x
    """
    solution = NP.linalg.lstsq(NP.vstack((NP.ones(len(x)), x)).T, y)
    return solution[0]


## the class itself

class Swipe(object):
    """
    Wrapper class representing a SWIPE' pitch extraction
    """

    def __init__(self, path, pmin=100., pmax=600., st=.3, dt=.001, 
                                                          mel=False):
        """
        Class constructor:

        path = either a file object pointing to a wav file, or a string path
        pmin = minimum frequency in Hz
        pmax = maximum frequency in Hz
        st = strength threshold (must be between [0.0, 1.0])
        dt = samplerate in seconds
        show_nan = if True, voiceless intervals are returned, marked as nan.
        """
        # Get Python path, just in case someone passed a file object
        f = path.name if hasattr(path, 'read') else path
        # check the path, quickly
        if not access(f, R_OK): 
            raise(IOError('File "{0}" not found'.format(f)))
        # Obtain the vector itself
        P = pyswipe(f, pmin, pmax, st, dt)
        # get function
        conv = None
        if mel: 
            conv = lambda hz: 1127.01048 * log(1. + hz / 700.)
        else: 
            conv = lambda hz: hz
        # generate
        tt = 0.
        self.t = []
        self.p = []
        if P.x < 1: 
            raise(ValueError('Failed to read audio'))
        for i in range(P.x):
            val = doublea_getitem(P.v, i)
            if not isnan(val):
                self.t.append(tt)
                self.p.append(conv(val))
            tt += dt

    def __str__(self):
        return '<Swipe pitch track with {0} points>'.format(len(self.t))

    def __len__(self):
        return len(self.t)

    def __iter__(self):
        return iter(zip(self.t, self.p))

    def __getitem__(self, t):
        """ 
        Takes a  argument and gives the nearest sample 
        """
        if self.t[0] <= 0.:
            raise ValueError, 'Time less than 0'
        i = bisect(self.t, t)
        if self.t[i] - t > t - self.t[i - 1]:
            return self.p[i - 1]
        else:
            return self.p[i]

    def _bisect(self, tmin=None, tmax=None):
        """ 
        Helper for bisection, but is a instance method
        """
        if not tmin:
            if not tmax:
                raise ValueError, 'tmin and/or tmax must be defined'
            else:
                return (0, bisect(self.t, tmax))
        elif not tmax:
            return (bisect(self.t, tmin), len(self.t))
        else:
            return (bisect(self.t, tmin), bisect(self.t, tmax))

    def slice(self, tmin=None, tmax=None):
        """ 
        Slice out samples outside of s [tmin, tmax] inline 
        """
        if tmin or tmax:
            (i, j) = self._bisect(tmin, tmax)
            self.t = self.t[i:j]
            self.p = self.p[i:j]
        else:
            raise ValueError, 'tmin and/or tmax must be defined'

    def select(self, tmin=None, tmax=None):
        """ 
        Select samples inside of s [tmin, tmax] inline 
        """
        if tmin or tmax:
            (i, j) = self._bisect(tmin, tmax)
            return zip(self.t[i:j], self.p[i,j])
        else:
            raise ValueError, 'tmin and/or tmax must be defined'

    def mean(self, tmin=None, tmax=None):
        """ 
        Return pitch mean 
        """
        if tmin or tmax:
            (i, j) = self._bisect(tmin, tmax)
            return _mean(self.p[i:j])
        else:
            return _mean(self.p)

    def median(self, tmin=None, tmax=None):
        """
        Return pitch median
        """
        if tmin or tmax:
            (i, j) = self._bisect(tmin, tmax)
            return _median(self.p[i:j])
        else:
            return _median(self.p)
    
    def var(self, tmin=None, tmax=None):
        """ 
        Return pitch variance 
        """
        if tmin or tmax:
            (i, j) = self._bisect(tmin, tmax)
            return NP.var(self.p[i:j])
        else:
            return NP.var(self.p)

    def sd(self, tmin=None, tmax=None):
        """ 
        Return pitch standard deviation 
        """
        return sqrt(self.var(tmin, tmax))

    def regress(self, tmin=None, tmax=None):
        """ 
        Return the linear regression intercept and slope for pitch ~ time,
        best used with Mel frequency (it is more likely to approximately
        satisfy the assumption that errors are normally distributed)
        """
        if tmin or tmax:
            (i, j) = self._bisect(tmin, tmax)
            return _regress(self.t[i:j], self.p[i:j])
        else:
            return _regress(self.t, self.p)
%}
