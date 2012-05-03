section .text
  global _start

_start:

  push dword len
	push dword msg
	push dword 1

	mov eax,0x4
	sub esp, 0x4
	int 0x80

	add esp, 0x10

	push dword 0x0

	mov eax, 0x1
	sub esp, 0x4
	int 0x80

section .data
  msg db "hello, world", 0xA
	len equ $-msg
