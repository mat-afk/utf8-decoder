%include "include/io.inc"

global _start

section .data
message: dq "Hello, world", 10
length:  equ $ - message

section .text
_start:
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, message
    mov rdx, length
    syscall

    mov rax, SYS_EXIT
    mov rdi, 0
    syscall
