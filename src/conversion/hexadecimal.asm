; gera_string_hexadecimal(int valor, char* buffer) 

; Converte o valor para hexadecimal maiúsculo
; com prefixo 0x,
; acrescenta LF e 
; termina a string com NUL.

; ISSO AINDA É UM PSEUDO-CÓDIGO E ESTOU CIENTE DE QUE CONTÉM MUITOS ERROS
; !!!!!!!!!!!!!!!!!!!!!!!!!!

section .text

gera_string_hexadecimal:

    mov rdx, valor ; recebe valor
    mov rdi, buffer ; recebe endereço do buffer

    ; 1. Adiciona prefixo 0x 
    mov i, 0
    mov byte [rdi + i], '0' ; buffer[0] = 0
    inc i
    mov byte [rdi + i], 'x' ; buffer[1] = x

    ; 2. Converte o valor de decimal para hexa

    ; while (valor != 0):
    ;   resultado = (int) valor / 16
    ;   resto = valor - 16 * resultado
    ; 
    ;   if resto < 10:
    ;       buffer[i] = resto + '0'
    ;   else:
    ;       buffer[i] = resto - 10 + 'A'
    ; 
    ;   valor = resultado
    ;   i++

    loop_while:
        ; while (valor != 0)
        cmp valor, 0
        jz end_first_while
        push valor

        shr valor, 4 ; resultado = valor / 16
        pop resto
        sub resto, [valor*16] ; resto = valor - 16 * resultado

        cmp resto, 10
        inc i ; i++
        jl add_algarismo
        jge add_letra

add_letra:
        sub resto, 10 
        add resto, 'A' ; transforma em caractere ASCII maiúsculo correspondente 
        mov byte [rdi + i], resto ; adiciona ao buffer
        jmp loop_while

add_algarismo:
        add resto, '0' ; transforma algarismo em caractere
        mov byte [rdi + i], resto ; adiciona ao buffer
        inc i ; i++
        jmp loop_while

    end_first_while: 

        ; 3. Adiciona LF
        inc i
        mov byte [rdi + i], 0x0A     ; buffer[len-2] = LF

        ; 4. Termina a string com NUL
        inc i
        mov byte [rdi + i], 0     ; buffer[len-1] = NUL

        ; 4. Arruma a ordem da string dentro de buffer
        mov j, 0
        loop_trocas:
            xchg [rdi + j], [rdi + i - j]
            inc j

            cmp i, i-j
            jne loop_trocas 