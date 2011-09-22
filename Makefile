# Python support isn't QUITE ready yet.

target=swipe
prefix=/usr/local

all: swipe 
#python

swipe: swipe.c vector.c	
	$(CC) $(CFLAGS) -o $(target) swipe.c vector.c -lm -lc -lblas -llapack -lfftw3 -lsndfile -Doldmain=main

#python:
	#swig -python swipe.i
	#python setup.py build_ext --inplace

install: swipe
	install swipe $(prefix)/bin
	#install _swipe.so ?
	#install _swipe.py ?
	#install _swipe.pyc ?

clean: 
	rm -f $(target) swipe_wrap.c swipe.py swipe.pyc _swipe.so
