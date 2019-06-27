IF      !DEF(FRAMEBUFFER_ASM)
FRAMEBUFFER_ASM     SET  1


; Calculate an address offset of hl
; Inputs
;   c = count
;   de = row width
; Outputs:
;   hl = hl + (c * de)
CALC_ADDR: MACRO
    ld      c, a
    inc     c
    jp      .calc_addr_skip\@
.calc_addr_loop\@:
    add     hl, de
.calc_addr_skip\@:
    dec     c
    jp      nz, .calc_addr_loop\@
    ENDM
ENDC
