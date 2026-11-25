%include "include/io.inc"
%include "io/stdin.asm"

global _start

section .data
message: db "Hello World", 0
length:  equ $ - message

section .text
_start:
    mov rdi, message
    mov rsi, 10
    call le_string
    
    cmp rax,0
    jle .end

    mov rdi, message
    call escreve_string
    
.end:
    mov rax, 60
    mov rdi, 0
    syscall
