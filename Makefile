

TGT=~/documents/lang/project.yml

all: install ctags

install:
	@python3 setup.py install --user --force 

clean: 
	@python3 setup.py clean 

ctags:
	ctags -R avocet
