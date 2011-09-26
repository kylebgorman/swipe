# Hand-crafted Makefile
# Kyle Gorman
# 
# By default, "make; make install" gives you Python support. If you don't want 
# this, then you can run "make c; make installc". If you want control the 
# installation root (e.g., /, /usr, /usr/local), set the $PREFIX environmental
# variable. "bin" is appended automatically. Similarly, you can make a binary
# called something other than "swipe" by setting the $TARGET environmental
# variable.

TARGET?=swipe
PREFIX?=/usr/local

all: c py
install: installc installpy

c: swipe.c vector.c
	$(CC) $(CFLAGS) -o $(TARGET) swipe.c vector.c -lm -lc -lblas -llapack -lfftw3 -lsndfile

installc: c
	install swipe $(PREFIX)/bin

swigpy:
	swig -python swipe.i

py:
	python setup.py -q build

installpy: py
	python setup.py -q install

clean:
	python setup.py clean
	rm -rf $(TARGET) swipe.pyc _swipe.so build/
