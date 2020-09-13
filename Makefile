CALL=python3 setup.py 

all: dev-install run 

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

run:
	avocet -vfD ls test
