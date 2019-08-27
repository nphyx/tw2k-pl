# yay, a makefile
build:
	swipl -o tw2k -g main -c tw2k.pl

examples: build
	./build_examples.sh
