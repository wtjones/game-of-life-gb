IF      !DEF(GAME_ASM)
GAME_ASM     SET  1

INCLUDE "gbhw.inc"

; Set a cell in the cell buffer and push to command list
; Inputs
;   b = x
;   c = y
;   h = value
; Destroys
;   de, hl
INIT_CELL: MACRO

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
