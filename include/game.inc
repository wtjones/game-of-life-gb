IF      !DEF(GAME_ASM)
DEF GAME_ASM = 1

INCLUDE "gbhw.inc"

; Set a cell in the cell buffer and push to command list
; Inputs
;   b = x
;   c = y
;   h = value
; Destroys
;   de, hl
MACRO INIT_CELL

    ; set_cell doesn't support unset, so make sure we need to set
    ld      a, h
    cp      1
    jr      nz, .skip_set_cell\@  ; if value = set
    push    bc
    push    hl
    call    set_cell
    pop     hl
    pop     bc
.skip_set_cell\@

    ld      d, b
    ld      e, c
    call    get_pixel_addr
    call    push_command_list
    ENDM
ENDC
