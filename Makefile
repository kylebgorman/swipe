PREFIX=/usr/local
CFLAGS=-std=c99 -O2 #with homebrew: -I/usr/local/Cellar/fftw/3.3.3/include -I/usr/local/Cellar/libsndfile/1.0.25/include -L/usr/local/Cellar/fftw/3.3.3/lib -L/usr/local/Cellar/libsndfile/1.0.25/lib

TARGET=swipe
WRAPPERS=$(TARGET)_wrap.c $(TARGET).py
PYLIBS=build/

all: $(TARGET) $(PYLIBS)

$(TARGET):
	$(CC) $(CFLAGS) -o $(TARGET) $(TARGET).c vector.c -lm -lc -lblas -llapack -lfftw3 -lsndfile

$(WRAPPERS):
	swig -python -threads $(TARGET).i

$(PYLIBS): $(WRAPPERS)
	python setup.py build

install: installc installpy

installc: $(TARGET)
	install $(TARGET) $(PREFIX)/bin

installpy: $(PYLIBS)
	python setup.py install --prefix=$(PREFIX) 

clean: 
	$(RM) -r $(TARGET) $(WRAPPERS) $(PYLIBS) king.wav *.pyc

test: swipe
	curl -O http://facstaff.bloomu.edu/jtomlins/Sounds/king.wav
	./$(TARGET) -r 50:400 -n -i king.wav
	python -c "import swipe; print swipe.Swipe('king.wav').regress()"
	$(RM) king.wav swipe.pyc

.PHONY: clean install test
