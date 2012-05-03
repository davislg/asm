win32: helloworld.obj
	alink -oPE helloworld.obj

helloworld.obj: helloworld.asm
	nasm -fobj helloworld.asm

clean:
	rm *.obj helloworld.exe

