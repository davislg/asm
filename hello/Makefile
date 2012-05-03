win32: hello.obj
	alink -oPE hello.obj

hello.obj: hello.asm
	nasm -fobj hello.asm

clean:
	rm *.obj hello.exe

