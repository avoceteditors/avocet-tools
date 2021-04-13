
DOCS_SRC=docs/source
DOCS_OUT=docs/build/dirhtml

TGT=~/documents/lang/project.yml

all: install doc ctags

install: install-avocet

install-avocet:
	make -C lib install-avocet

clean: 
	@python3 setup.py clean 

ctags:
	ctags -R lib

doc: docs-build docs-rsync

docs-build:
	sphinx-build -aEb dirhtml $(DOCS_SRC) $(DOCS_OUT)

docs-rsync:
	@rsync -qvr --del $(DOCS_OUT)/* /var/www/html/avocet-tools
