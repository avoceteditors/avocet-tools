CALL=python3 setup.py 

all: dev-install 

run: run-parse

dev-install:
	@$(CALL) build_ext 
	@$(CALL) install --user --force

install:
	@$(CALL) build_ext 
	@sudo $(CALL) install

clean: cython-clean python-clean

python-clean:
	@$(CALL) clean 

cython-clean:
	@rm avocet/*/*.c


run-ls:
	avocet -vfD ls test

run-parse:
	avocet -vfD parse test
