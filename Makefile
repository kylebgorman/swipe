PREFIX=/usr/local
CFLAGS=-O2

TARGET=swipe
WRAPPER=$(TARGET)_wrap.c
PYWRAP=$(TARGET).py
PYLIBS=build/

all: $(TARGET) $(PYLIBS)

$(TARGET):
	$(CC) $(CFLAGS) -o $(TARGET) $(TARGET).c vector.c -lm -lc -lblas -llapack -lfftw3 -lsndfile

$(WRAPPER) $(PYWRAP):
	swig -python -threads $(TARGET).i

$(PYLIBS): $(WRAPPER) $(PYWRAP)
	python setup.py build

install: installc installpy

installc: $(TARGET)
	install $(TARGET) $(PREFIX)/bin

installpy: $(PYLIBS)
	python setup.py install

clean: 
	$(RM) -r $(PYLIBS) $(TARGET) $(WRAPPER) $(PYWRAP)

test: swipe
	curl -O http://facstaff.bloomu.edu/jtomlins/Sounds/king.wav
	./$(TARGET) -ni king.wav
	python -c "import swipe; print swipe.Swipe('king.wav').regress(tmax=2.)"
	$(RM) king.wav

.PHONY: clean install test
