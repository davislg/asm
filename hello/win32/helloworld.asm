;; When symbols are not defined within our program, we need to use 'extern', to tell NASM that those will be assigned when the program is linked. 

;; These are the symbols for the Win32 API import functions we will use. 

extern GetStdHandle 

extern WriteFile 

extern AllocConsole 

extern FreeConsole 

extern SetConsoleTitleA 

extern SetConsoleCursorPosition 

extern Sleep 

extern ExitProcess 


;; Now, we need a symbol import table, so that we can import Win32 API functions from their DLLs. 

;; Note, though, that some functions have ANSI and unicode versions; for those, a name suffix is 

;; required (ie "<function_name>A" for ANSI, and "<function_name>W" for unicode; SetConsoleTitleA 

;; is an example of one). 

import GetStdHandle kernel32.dll 

import WriteFile kernel32.dll 

import AllocConsole kernel32.dll 

import FreeConsole kernel32.dll 

import SetConsoleTitleA kernel32.dll 

import SetConsoleCursorPosition kernel32.dll 

import Sleep kernel32.dll 

import ExitProcess kernel32.dll 


;; Here, we tell NASM to put the following stuff into the code section of the program. 

;; The 'use32' tells NASM to use 32-bit code, and not 16-bit code. 

section .text use32 

;; The '..start:' special symbol tells NASM (and, later on, the linker) that this is 

;; where the program entry point is. This is where the instruction pointer will point 

;; to, when the program starts running. 

..start: 


;; Since this is a Windows subsystem program, we need to allocate a console, 

;; in order to use one. 

;; Note how we use 'AllocConsole' as if it was a variable. 'AllocConsole', to 

;; NASM, means the address of the AllocConsole "variable" ; but since the 

;; pointer to the AllocConsole() Win32 API function is stored in that 

;; variable, we need to call the address from that variable. 

;; So it's "call the code at the address: whatever's at the address AllocConsole" . 

call [AllocConsole] 


;; Here, we push the address of 'the_title' to the stack. 

push dword the_title 

;; And we call the SetConsoleTitleA() Win32 API function. 

call [SetConsoleTitleA] 


;; We push -11 (yes, that's legal, it basically means 0 - 11, in two's complement), 

;; which is the Windows constant for STD_OUTPUT_HANDLE, to the stack. 

push dword -11 

;; Then we call the GetStdHandle. 

call [GetStdHandle] 

;; The Win32 API functions return the result in the EAX register. 

;; Therefore, to save the return, we need to save the value in EAX. 

;; Here, we move the value from EAX to [hStdOut] ("to the memory location 

;; at the address hStdOut"). 

mov dword [hStdOut], eax 


;; We move the address of msg_len to EAX. 

mov eax, msg_len 

;; Then we subtract the address of msg from EAX, to get the 

;; size of the msg variable, since msg_len comes right after msg. 

sub eax, msg 

;; Since there's a trailing 0, the actual text is really 1 byte less. 

;; So we decrement (or subtract 1 from) EAX. 

dec eax 

;; Then we save that result in the msg_len variable. 

mov dword [msg_len], eax 


;; WriteFile() has 5 parameters. 

;; When we call a function in assembly language, we push the parameters 

;; to the stack in backwards order, so that it's easier for the function 

;; we're calling to access these parameters, because for that function 

;; the parameters will actually be in the correct order, because of 

;; the way the Intel procedure stack works. 


;; The fifth parameter is usually 0. 

push dword 0 

;; The fourth parameter is the address of the variable where we want 

;; the actual number of bytes written (or read, for ReadFile()) saved. 

push dword nBytes 

;; The third parameter is the number of bytes to write (or read, for ReadFile()). 

push dword [msg_len] 

;; The second parameter is the pointer to the buffer where 

;; the text to write (or read, for ReadFile()), is located. 

push dword msg 

;; The first parameter is the handle to the file we want to write to 

;; (or read from, for the ReadFile() function). 

push dword [hStdOut] 

;; Then we call the Win32 API WriteFile() function. 

call [WriteFile] 


;; It's time to set the console cursor position. 

;; We want to set the high-order part of EAX to 

;; the new Y coordinate of the console cursor 

;; and the low-order part of EAX to the new 

;; X coordinate of the console cursor. 


;; Set the low-order part of EAX to 15. 

mov ax, 15 

;; Shift the bits in EAX left, so that 

;; the high-order part of EAX is 15, now. 

shl eax, 16      ;; EAX is 32 bits in size, so it would make sense to 

                 ;; shift things by 16 bits. 

                 ;; Note that AX is not 15 anymore, because the 15 

                 ;; has been shifted. AX should be 0, at this point. 

;; Set the low-order part of EAX to 0. 

mov ax, 0        ;; I know it's kind of silly to set AX to 0 if it 

                 ;; should already be 0, but we do that anyway. 

;; The second parameter to the SetConsoleCursorPosition() function 

;; is a COORD structure (that we just made) for the new 

;; position of the console cursor. 

push eax 

;; The first parameter is the standard output handle of the console 

;; of which we want to set the cursor. 

push dword [hStdOut] 

;; Then we call the Win32 API SetConsoleCursorPosition() function. 

;; It's the same thing as pushing the EIP and jumping to the 

;; function, but we can't directly access EIP, so we have to 

;; use the CALL instruction. 

call [SetConsoleCursorPosition] 


;; Sleep() is a Win32 API function that suspends the execution of 

;; the current code for a number of milliseconds that we specify. 

;; So we specify 2000 milliseconds (2 seconds). 

push dword 2000 

;; And we call the Sleep() function. 

call [Sleep] 


;; When we're done using the console, we need to free it, 

;; if we were the ones who allocated it. 

;; Same applies for other resources, such as file handles 

;; and memory pointers; like if we open a file, we need to 

;; close the handle after we're done using the file. 

call [FreeConsole] 


;; XOR reg, reg is a way to clear reg, so that it's 0. 

xor eax, eax 

;; We pass EAX (which is 0) to ExitProcess(). 

push eax 

;; Then we call the ExitProcess() Win32 API function. 

call [ExitProcess] 


;; Now we tell NASM that this next stuff is supposed to go 

;; into the data section. 

section .data 

;; We define the_title, and initialize it to "HelloWorldProgram" 

the_title                  db "HelloWorldProgram", 0 

;; Now we define msg, and initialize that to "Hello World! \r\n" 

msg                        db "Hello World! ", 13, 10, 0 

                                 ;; Note that 13 means "\r" and 10 means "\n" 

                                 ;; 13 is the ASCII code for carriage return (CR) 

                                 ;; and 10 is the ASCII code for line feed (LF) 

                                 ;; CRLF is the character combination used for 

                                 ;; new lines (or at least under DOS/Windows). 

;; Since msg_len has to come right after msg, 

;; in order for us to get correct results in 

;; the above code, we have to define it right 

;; after msg and in the data section. 

;; We can initialize it to whatever we want, 

;; since it will be changed, later on, anyway. 

;; I decided to initialize it to 0. 

msg_len                    dd 0 


;; Here we tell NASM that the following is for the bss section. 

section .bss 

;; We reserve 1 double-word for hStdOut. 

hStdOut                    resd 1 

;; And we reserve 1 double-word for nBytes. 

nBytes                     resd 1 