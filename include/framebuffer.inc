IF      !DEF(FRAMEBUFFER_ASM)
FRAMEBUFFER_ASM = 1

INCLUDE "gbhw.inc"

FRAMEBUFFER_MAX         EQU 250 * 64    ; Must use fewer than 255 tile indexes
                                        ; to account for the border, so
                                        ; 160 * 100 / 64 = 250 is max usable
                                        ; tiles possible.
FRAMEBUFFER_WIDTH       EQU 32
FRAMEBUFFER_HEIGHT      EQU 32

; Calculate an address offset of hl
; Inputs
;   c = count
;   de = row width
; Outputs:
;   hl = hl + (c * de)
; Destroys
;   c
MACRO CALC_ADDR
    inc     c
    jp      .calc_addr_skip\@
.calc_addr_loop\@:
    add     hl, de
.calc_addr_skip\@:
    dec     c
    jp      nz, .calc_addr_loop\@
    ENDM
ENDC
