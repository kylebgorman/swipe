PREFIX=/usr/local
CFLAGS=-O2

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
	python setup.py install

clean: 
	$(RM) -r $(TARGET) $(WRAPPERS) $(PYLIBS) king.wav *.pyc

test: swipe
	curl -O http://facstaff.bloomu.edu/jtomlins/Sounds/king.wav
	./$(TARGET) -r 50:400 -n -i king.wav
	python -c "import swipe; print swipe.Swipe('king.wav').regress()"
	$(RM) king.wav swipe.pyc

.PHONY: clean install test
