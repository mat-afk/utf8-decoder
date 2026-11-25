; ----------------------------------------------------------------
; stdin.asm
;
; Faz a entrada e saída de strings
;
; Implementa:
; |- le_string
; |- escreve_string
;
; Exporta:
; |- le_string
; |- escreve_string
;   
; ----------------------------------------------------------------

section .text

; ----------------------------------------------------------------
; le_string(char* buffer, int tam_max)
;
; Decodifica uma sequência UTF-8 de até 4 bytes em seu code
; point Unicode correspondente.
;
; Parâmetros:
;   [rdi] = buffer
;   [rsi] = tam_max
;
; Retorna:
;   RAX =  quantidade de caracteres lidos 
;   RAX = -1 em caso de erro de leitura
;
; Pré-condição:
;   A sequência UTF-8 é válida.
; ----------------------------------------------------------------

global le_string


le_string:
    ; Configura sys_read
    mov rax, 0        ; Numero da syscall
    mov rdx, rsi      ; numero max de bytes a serem lidos
    mov rsi, rdi      ; Endereço do buffer
    dec rdx           ; Deixa espaço pra nul
    mov rdi, 0        ; Descritor de arquivo 0 para stdin
    syscall

    test rax, rax     ; testa para ver se 
    jle .error

    cmp byte [rsi + rax - 1],0xA ; Compara para ver se o ultimo byte é '\n'
    ; 'Hello World\n' pularia e \n seria substituido em end
    ; 'Hello World' não pularia, rax não seria decrementado e 
    ;  o byte 'reservado' anteriormente seria preenchido
    ;  por 0
    jnz .end
    dec rax            ; Não conta \n

.end:
    mov byte [rsi + rax], 0 ; Coloca nul ao fim
    ret

.error:
    mov byte [rsi], 0   ; esvazia o buffer
    mov rax,-1          ; retorna -1 em erro
    ret

; ----------------------------------------------------------------
; escreve_string(char* buffer)
;
; Escreve na saída padrão uma string terminada em NUL. Usa sys_write.
;
; Parâmetros:
;   [rdi] = buffer
;
; Retorna:
;   RAX =  quantidade de caracteres escritos
;
; Pré-condição:
;     String existente e terminada em 0
; ----------------------------------------------------------------

global escreve_string


escreve_string:
    ; Configura sys_write
    mov rax, 1
    mov rsi, rdi      ; Endereço do buffer
    mov rdi, 1        ; Descritor de arquivo 1 para stdout
    mov rdx, 0        ; Inicializa o contador de bytes
    
.while:
    cmp byte [rsi + rdx], 0 ; vê se chegou ao nul
    jz  .end    ;se chegou termina
    inc rdx     ;se não continua o loop 
    jmp .while

.end:
    syscall
    ret
