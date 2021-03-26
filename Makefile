

TGT=~/documents/lang/project.yml

TRACE=-DENABLE_TRACE -DENABLE_DEBUG
DEBUG=-DENABLE_DEBUG

BOOST_INCS=-I/usr/include/boost -lboost_filesystem -lboost_system
PKG=pkg-config --libs --cflags
YAML_INCS=$(shell $(PKG) yaml-cpp)
GLIB=$(shell $(PKG) glib-2.0)
GLIBMM=$(shell $(PKG) glibmm-2.4)

CC=clang++

DEPS=$(BOOST_INCS) $(YAML_INCS) $(GLIB) $(GLIBMM)

dev: ctags build-debug test

build-trace:
	$(CC) -o bin/avocet $(TRACE) $(DEPS) src/avocet.cpp

build-debug:
	$(CC) -o bin/avocet $(DEBUG) $(DEPS) src/avocet.cpp

build-norm:
	$(CC) -o bin/avocet $(DEPS) src/avocet.cpp
ctags:
	ctags -R src 

test:
	./bin/avocet -C $(TGT)


