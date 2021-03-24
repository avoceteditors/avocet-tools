

TGT=~/documents/lang/project.yml

dev: ctags build-dev

build-dev:
	@scons debug=True

trace:
	@scons trace=True

ctags:
	ctags -R src 
