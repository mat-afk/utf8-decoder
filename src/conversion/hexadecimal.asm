; ----------------------------------------------------------------
; hexadecimal.asm
;
; Converte valores inteiros para a base hexadecimal,
; gerando uma string com os caracteres correspondentes.
;
; Implementa:
; |- gera_string_hexadecimal(int valor, char* buffer) 
;
; Exporta:
; |- gera_string_hexadecimal
; ----------------------------------------------------------------

global gera_string_hexadecimal

section .text

; ----------------------------------------------------------------
; gera_string_hexadecimal(int valor, char* buffer) 
;
; Converte o valor para hexadecimal maiúsculo
; com prefixo 0x,
; acrescenta LF e 
; termina a string com NUL.
; Armazena resultado em buffer.
;
; Parâmetros:
;   [rbp + 16] = valor
;   [rbp + 24] = buffer
;
; Retorna:
;   A função não possui valores de retorno.
;
; Pré-condições:
;   Valor é um code point Unicode válido.
;   Buffer é um endereço válido com espaço suficiente para a string.
; ----------------------------------------------------------------

gera_string_hexadecimal:
    push rbp                           ; topo da pilha
    mov rbp, rsp
    mov rax, [rbp + 16]                ; rax recebe valor
    mov rdi, [rbp + 24]                ; rdi recebe endereço do buffer

    ; 1. ADICIONA PREFIXO 0x EM BUFFER
    mov byte [rdi], '0'                ; buffer[0] = 0
    mov byte [rdi + 1], 'x'            ; buffer[1] = x

    ; 2. CONVERTE O VALOR DE DECIMAL PARA HEXA (RETORNA REPRESENTAÇÃO INVERTIDA NO BUFFER)
    mov r8, 2                          ; r8 armazena índices i relativos às posições do buffer
    push r8                            ; armazena posição de início da inversão do buffer

    cmp rax, 0                         ; sse valor = 0
    jne .loop_while
    mov byte [rdi + r8], '0'           ; buffer = 0x0
    inc r8
    jmp .end_first_while

    .loop_while:
        ; while (valor != 0)
        cmp rax, 0
        jz .end_first_while 

        push rax                       ; armazena valor original na pilha
        shr rax, 4                     ; resultado = (int) valor / 16

        pop rdx                        ; rdx armazena valor original
        shl rax, 4                     ; 16 * resultado
        sub rdx, rax                   ; rdx armazena resto da divisão

        cmp rdx, 10
        jl .add_algarismo               ; if resto < 10

    .add_letra:
        ; buffer[i] = resto - 10 + 'A'
        sub rdx, 10 
        add rdx, 'A'                   ; caractere ASCII maiúsculo correspondente 

        mov byte [rdi + r8], dl        ; adiciona ao buffer
        inc r8                         ; i++
        jmp .loop_while

    .add_algarismo:
        ; buffer[i] = resto + '0'
        add rdx, '0'                   ; caractere correspondente

        mov byte [rdi + r8], dl        ; adiciona ao buffer
        inc r8                         ; i++
        jmp .loop_while

    .end_first_while: 
        dec r8
        push r8                        ; armazena índice final da região invertida do buffer

        ; 3. ADICIONA LF E TERMINA STRING COM NUL
        inc r8
        mov byte [rdi + r8], 0x0A      ; buffer[len-2] = LF
        inc r8 
        mov byte [rdi + r8], 0         ; buffer[len-1] = NUL
        cmp rax, 0                     ; sse valor = 0
        je .end_conversao               ; conversão está completa

    ; 4. ARRUMA A ORDEM DA STRING INSERIDA EM BUFFER
    .reordenar:
        pop r11                        ; índice do fim da inversão 
        pop r10                        ; índice do início da inversão
        mov r9, 0                      ; posição relativa para identificar e trocar pares

        ; buffer está invertido de buffer[r10] a buffer[r11]
        .loop_trocas:
            ; while (r9 < (fim-inicio+1)/2)
            mov r12, r11
            sub r12, r10
            inc r12
            shr r12, 1

            cmp r9, r12
            jge .end_conversao

            ; calcula os índices do par (buffer[r10+r9] e buffer[r11-r9])
            lea r12, [r10+r9]          ; r12 = r10 + r9
            mov r13, r11
            sub r13, r9                ; r13 = r11 - r9

            ; troca valores do par
            mov dl, [rdi + r13]
            xchg dl, [rdi + r12]
            mov [rdi + r13], dl

            ; retoma loop para próximo par
            inc r9
            jmp .loop_trocas

    .end_conversao:
        mov rsp, rbp
        pop rbp
        ret