IF      !DEF(GAME_ASM)
GAME_ASM     SET  1

INCLUDE "gbhw.inc"

; Set a cell in the cell buffer and push to command list
; Inputs
;   b = x
;   c = y
; Destroys
;   de, hl
INIT_CELL: MACRO
    push    bc
    call    set_cell
    pop     bc
    ld      d, b
    ld      e, c
    ld      h, 1
    call    get_pixel_addr
    call    push_command_list
    ENDM
ENDC
