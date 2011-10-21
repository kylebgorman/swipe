SWIPE' pitch estimator, v. 1.3
==============================

Based on Camacho, Arturo. A sawtooth waveform inspired pitch estimator for
speech and music. Doctoral dissertation, University of Florida. 2007.

Implemented in C by Kyle Gorman <kgorman@ling.upenn.edu>

How to Cite:
------------

Please cite this dissertation, and if possible include a URL to this program
source, the most-recent version of which will always be at:

`http://ling.upenn.edu/~kgorman/c/swipe/`

How to install:
---------------

For all platforms: To compile, type "make" at the terminal. To install, type 
"make install" at the terminal. You may specify '--prefix=PATH/TO/LOCATION' if
you wish; the default is /usr/local, which places swipe in /usr/local/bin.

If you do not wish to have make use of Python support, you can install the 
binary only by issuing "make c; make installc".
  
Linux: All the large libraries should be available as packages if you're using 
a "modern" distro. For instance, on a current Debian/Ubuntu system (Ubuntu 
9.04, "Jaunty Jackalope", kernel 2.6.28-13-generic), I ran (as superuser):

$ apt-get install liblibblas-dev liblapack-dev libfftw3-dev libsndfile1-dev

This installs the necessary libraries and all their dependencies. Similar
incantations are available for other Linux distributions.

Mac OS X: The linear algebra libraries ([C]LAPACK, BLAS) ship with Mac OS X.
You will need to install the newest versions of fftw3 and libsndfile, however. 
They are available for free online:

http://www.fftw.org/
http://www.mega-nerd.com/libsndfile/

If you are superuser and wish to install globally the autoconf method should 
work fine:

    tar -xvzf downloadedPackage.tar.gz
    cd folderOfPackageCreatedByUnTARring/
    ./configure; make; make install;

If you're not superuser, or don't want to install globally, make sure to use 
'--prefix=PATH/TO/LOCATION' as an argument to 'configure'. You may need to 
alter the #include statements as well.

These two libraries are also available via fink or DarwinPorts.

Windows/CYGWIN: Unsupported. Send details of any successes, however.

Audio file formats:
-------------------

All mono-channel audio recognized by libsndfile is accepted. For a list, see:

http://www.mega-nerd.com/libsndfile/#Features

Miscellany:
-----------

I also included the original MATLAB code from Camacho. There is also a Python 
module which calls the swipe code directly. This has only slightly more
overhead than the "-b" batch method from C, if you're going to use a scripting 
language to do later processing anyways. The following example session (plus 
the docstrings) should get you started:

    >>> from swipe import Swipe
    >>> P = Swipe('test.wav', pmin=75, pmax=500, st=.5, dt=0.01, mel=False)
    >>> for (t, pitch) in P:
    ...     if pitch > 200:  # hz
    ...         print t, pitch
    ...
    ...
    ...
    0.1 181.055641496
    0.11 181.811640687
    0.12 182.419065658
    0.13 182.267034374
    0.14 181.963321962
    0.15 181.811640687
    0.16 181.660075933
    1.25 180.753790055
    1.26 181.811640687
    >>> print P.median()
    168.737503785
    >>> print P.var()
    129.630995655
    >>> P.slice(2.5, 3) # remove the samples not between 2.5 and 3 seconds
    >>> (intercept, slope) = P.regress()
    >>> print slope  # dropping 36 Hz a second in that interval
    -35.9938275598
