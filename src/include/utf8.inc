; ----------------------------------------------------------------
; utf8.inc
;
; Define constantes relacionadas ao módulo de UTF-8.
; ----------------------------------------------------------------

UTF8_1_MASK      equ 0x80       ; 10000000

UTF8_2_MASK      equ 0xE0       ; 11100000
UTF8_2_X         equ 0x1F       ; 00011111
UTF8_2_PATTERN   equ 0xC0       ; 110xxxxx

UTF8_3_MASK      equ 0xF0       ; 11110000
UTF8_3_X         equ 0x0F       ; 00001111
UTF8_3_PATTERN   equ 0xE0       ; 1110xxxx

UTF8_4_MASK      equ 0xF8       ; 11111000
UTF8_4_X         equ 0xF8       ; 00000111
UTF8_4_PATTERN   equ 0xF0       ; 11110xxx

UTF8_CONT_MASK   equ 0x3F       ; 00111111
