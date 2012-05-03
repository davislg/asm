win32: hello.obj
	link /subsystem:console /nodefaultlib /entry:start  hello.obj

hello.obj: hello.asm
	nasm -fwin32 hello.asm

clean:
	rm *.obj hello.exe

