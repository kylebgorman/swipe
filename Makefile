# Python support isn't QUITE ready yet.

target=swipe
prefix=/usr/local

all: swipe python

swipe: swipe.c vector.c	
	$(CC) $(CFLAGS) -o $(target) swipe.c vector.c -lm -lc -lblas -llapack -lfftw3 -lsndfile

python:
	swig -python swipe.i
	python setup.py -q build

install: swipe
	install swipe $(prefix)/bin
	python setup.py -q install

clean: 
	python setup.py clean
	rm -rf $(target) swipe_wrap.c swipe.py swipe.pyc _swipe.so build/
