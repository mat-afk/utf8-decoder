; ----------------------------------------------------------------
; utf8.asm
;
; Decodifica caracteres UTF-8 e reconstrói seus respectivos code
; points em Unicode.
;
; Implementa:
; |- decodifica_utf8
; |- incorpora_continuacao
;
; Exporta:
; |- decodifica_utf8
;
; Depende de:
; |- io/files.asm -> le_byte_arquivo
; |- include/utf8.inc
; ----------------------------------------------------------------

%include "io/files.asm"
%include "include/utf8.inc"

section .text

; ----------------------------------------------------------------
; decodifica_utf8(int primeiro_byte, int descritor_arquivo)
;
; Parâmetros:
;   [rbp + 16] = primeiro_byte
;   [rbp + 24] = descritor_arquivo
;
; Retorna:
;   RAX = code point Unicode
;   RAX = -1 em caso de erro de leitura
;
; Pré-condição:
;   A sequência UTF-8 é válida.
; ----------------------------------------------------------------

global decodifica_utf8

decodifica_utf8:
    push rbp                        ; Salva o valor antigo de RBP na pilha
    mov rbp, rsp                    ; Faz RBP apontar para essa posição, estabeleçenco a referência do quadro da função
    sub rsp, 16                     ; Reserva 16 bytes para variáveis locais

    mov qword [rbp - 8], 0          ; [rbp - 8]  = code point parcial
    mov qword [rbp - 16], 0         ; [rbp - 16] = quantidade de bytes de continuação restantes

    movzx eax, byte [rbp + 16]      ; EAX (32-bit) = primeiro_byte completado com zeros à esquerda

    ; Vamos identificar o tamanho da sequência. Veja a tabela:
    ;
    ; -----------------------------
    ; | primeiro_byte | n byte(s) |
    ; -----------------------------
    ; | 0xxxxxxx      | 1         |
    ; | 110xxxxx      | 2         |
    ; | 1110xxxx      | 3         |
    ; | 11110xxx      | 4         |
    ; -----------------------------
    ;
    ; Lembre EAX = primeiro_byte. Começamos EDX = EAX e, então, selecionamos os n-ésimos primeiros bits com
    ;
    ;   and edx, UTF8_{n}_MASK
    ;
    ; onde os n primeiros bits de UTF8_{n}_MASK são 1's e o resto é zero. Depois, vemos a qual padrão os n primeiros bits correspondem com
    ;
    ;   cmp edx, UTF_{n}_PATTERN
    ;
    ; e concatemos os x bits ao code point parcial na seção específica dos n bytes
    ;
    ;   je .{n}_byte(s)
    ;
    ; Note que, quando n = 1, usamos
    ;
    ;   cmp eax, 0x80
    ;   jb .one_byte
    ;
    ; porque 0xxxxxxx < 10000000 = 0x80 para quaisquer x.

    ; 1 byte: primeiro_byte = 0xxxxxxx se e somente se primeiro_byte < 10000000
    cmp eax, 0x80
    jb .one_byte

    ; 2 bytes: primeiro_byte = 110xxxxx
    mov edx, eax
    and edx, 0xE0
    cmp edx, 0xC0
    je .two_bytes

    ; 3 bytes: primeiro_byte = 1110xxxx
    mov edx, eax
    and edx, 0xF0
    cmp edx, 0xE0
    je .three_bytes

    ; 4 bytes: primeiro_byte = 11110xxx
    mov edx, eax
    and edx, 0xF8
    cmp edx, 0xF0
    je .four_bytes

    ; n > 4 bytes: não é uma sequência UTF-8 válida
    jmp .error

; Agora, para cada n-sequência, vamos concatenar os bits x que pertencem ao code point = [RBP - 8]. Lembre que, para n > 1, os bytes de continuação
; sempre são da forma 10xxxxxx.

; Se n = 1, então sequência = 0xxxxxx. Retirar a máscara não faz diferença ao code point final, então simplesmente atribuímos
; code point parcial = [RBP - 8] = EAX.
.one_byte:
    mov [rbp - 8], rax
    jmp .done

; Se n = 2, então sequência = 110xxxxx 10xxxxxx
.two_bytes:
    and eax, 0x1F                   ; Seleciona os bits x do EAX = primeiro_byte = 110xxxxx usando 0x1F = 00011111
    mov [rbp - 8], rax              ; Põe RAX em code point parcial = [RBP - 8]

    mov qword [rbp - 16], 1         ; Falta um byte de continuação 10xxxxxx
    jmp .decode_continuations

; Se n = 3, então sequência = 1110xxxx 10xxxxxx 10xxxxxx
.three_bytes:
    and eax, 0x0F                   ; Seleciona os bits x do EAX = primeiro_byte = 110xxxxx usando 0x0F = 00001111
    mov [rbp - 8], rax              ; Põe RAX em code point parcial = [RBP - 8]

    mov qword [rbp - 16], 2         ; Faltam dois byte de continuação 10xxxxxx 10xxxxxx
    jmp .decode_continuations

; Se n = 4, então sequência = 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
.four_bytes:
    and eax, 0xF8                   ; Seleciona os bits x do EAX = primeiro_byte = 11110xxx usando 0xF8 = 11111000
    mov [rbp - 8], rax              ; Põe RAX em code point parcial = [RBP - 8]

    mov qword [rbp - 16], 3         ; Faltam dois byte de continuação 10xxxxxx 10xxxxxx 10xxxxxx
    jmp .decode_continuations

.decode_continuations:

.loop:
    cmp qword [rbp - 16], 0         ; Para se já não há bytes de continuação para serem lidos
    je .done

    lea rax, [rbp - 8]
    push rax                        ; RAX = [rbp - 8] = code point parcial
    push qword [rbp + 24]           ; [RBP + 24] = descritor do arquivo de entrada
    call incorpora_continuacao
    add rsp, 16

    test rax, rax                   ; Verifica se o retorno tem sinal, isto é, se RAX = -1
    js .error

    dec qword [rbp - 16]            ; Incorporamos um byte de continuação, então decrementamos [RBP - 16] = bytes restantes

    jmp .loop

; Se não houve erro na leitura dos bytes, atribuímos RAX = [RBP - 8] = code point parcial
.done:
    mov rax, [rbp - 8]
    jmp .epilogue

; Se n > 4, não é uma sequência válida e atribuímos RAX = -1
.error:
    mov rax, -1

; Higienização da pilha e finalização
.epilogue:
    mov rsp, rbp                    ; Descarta variáveis locais
    pop rbp                         ; Recupera o RBP da função chamadora
    ret                             ; Retira o endereço de retorno da pilha e continua no chamador


; ----------------------------------------------------------------
; incorpora_continuacao(int descritor_arquivo, char* unicode)
;
; Lê um byte de continuação UTF-8 e incorpora seus 6 bits ao code
; point em construção
;
; Parâmetros:
;   [rbp + 16] = descritor do arquivo de entrada
;   [rbp + 24] = endereço do code point em construção
;
; Retorna:
;   RAX = 0 se a incorporação foi bem secedida
;   RAX = -1 em caso de erro de leitura
;
; Pré-condição:
;   A sequência UTF-8 é válida.
; ----------------------------------------------------------------

incorpora_continuacao:
    push rbp
    mov rbp, rsp
    sub rsp, 8                      ; Reserva espaço para uma variável local, de 8 bytes

    ; [rbp - 1] = byte de continuação lido

    lea rax, [rbp - 1]
    push rax                        ; RAX = [rbp - 1] = code point em construção
    push qword [rbp + 16]           ; [rbp + 16] = descritor do arquivo de entrada
    call le_byte_arquivo
    add rsp, 16

    cmp rax, 1                      ; Verificamos se le_byte_arquivo leu somente o próximo byte do arquivo. Lembre que ela retorna RAX = número de bytes lidos.
    jne .error

    movzx eax, byte [rbp - 1]       ; Extrai os 6 bits do byte usando 0x3F = 00111111
    and eax, 0x3F

    mov rdx, [rbp + 24]             ; Atribui o code point em construção ao code point local
    shl qword [rdx], 6              ; Shifta o novo code point 6 bits à esquerda
    or qword [rdx], rax             ; Põe os novos bits em RDX

    xor eax, eax                    ; Verifica se foi um sucesso
    jmp .epilogue

; A leitura não foi bem sucedida, então RAX = -1
.error:
    mov rax, -1

; Higienização da pilha e finalização
.epilogue:
    mov rsp, rbp                    ; Descarta variáveis locais
    pop rbp                         ; Recupera o RBP da função chamadora
    ret                             ; Retira o endereço de retorno da pilha e continua no chamador
