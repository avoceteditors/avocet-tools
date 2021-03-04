
EXE=avocet

CFLAGS=-std=c++17
INCS=-I/usr/include -I/usr/include/boost -I/usr/include/tclap
SRC=$(wildcard src/*.cpp) $(wildcard src/*.hpp)

TGT=~/documents/lost/project.yml
CALL=python3 setup.py 

all: dev-install 

run: run-compile

dev-install:
	#@$(CALL) build_ext 
	@$(CALL) install --user --force 

install:
	@$(CALL) build_ext 
	@sudo $(CALL) install

clean: cython-clean python-clean

python-clean:
	@$(CALL) clean 

cython-clean:
	@rm avocet/*.c

run-compile:
	avocet -avD compile $(TGT) 
