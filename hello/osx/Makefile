build: hello.o
	ld -o hello -e start -macosx_version_min 10.7.0 hello.o	

hello.o: hello.asm
	nasm -f macho hello.asm

clean:
	rm *.o hello

