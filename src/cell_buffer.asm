INCLUDE "framebuffer.inc"

CELL_BUFFER_WIDTH   EQU FRAMEBUFFER_WIDTH
CELL_BUFFER_HEIGHT  EQU FRAMEBUFFER_HEIGHT
CELL_BUFFER_BYTES   EQU FRAMEBUFFER_WIDTH * FRAMEBUFFER_HEIGHT / 8  ; one bit
                                                                    ; per cell

SECTION "cell buffer vars", WRAM0

cell_buffer_0: DS CELL_BUFFER_BYTES
cell_buffer_1: DS CELL_BUFFER_BYTES
current_cell_buffer: DS 2
successor_cell_buffer: DS 2

SECTION "cell buffer utility", ROM0

init_cell_buffer::
    ld      hl, cell_buffer_0
    ld      bc, CELL_BUFFER_BYTES
    ld      a, $0
    call    mem_Set
    ld      hl, cell_buffer_1
    ld      bc, CELL_BUFFER_BYTES
    ld      a, $0
    call    mem_Set

    ld      hl, current_cell_buffer
    ld      de, cell_buffer_1
    ld      a, d
    ld      [hl+], a
    ld      a, e
    ld      [hl], a

    ld      hl, successor_cell_buffer
    ld      de, cell_buffer_0
    ld      a, d
    ld      [hl+], a
    ld      a, e
    ld      [hl], a

    ret

get_current_cell_buffer::
    ld      hl, current_cell_buffer
    ld      d, [hl+]
    ld      e, [hl]
    push    de
    pop     hl
    ret



; Writes to the sucessor buffer
; Inputs
;   b = x
;   c = y
;   d = value
set_cell::
    ld      hl, successor_cell_buffer
    ld      a, [hl+]
    ld      d, a
    ld      a, [hl]
    ld      l, a
    ld      h, d

    ld      de, CELL_BUFFER_WIDTH / 8

    CALC_ADDR   ; hl = buffer + (y * CELL_BUFFER_WIDTH / 8)
                ; hl now points to start of desired row

    ;

    ret
