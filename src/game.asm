INCLUDE "framebuffer.inc"

CELL_BUFFER_WIDTH EQU FRAMEBUFFER_WIDTH
CELL_BUFFER_HEIGHT EQU FRAMEBUFFER_HEIGHT

SECTION "game vars", WRAM0

cell_buffer_0:: DS 2048
cell_buffer_1:: DS 2048


SECTION "framebuffer utility", ROM0


init_game::
    call get_current_cell_buffer;   buffer in hl

    ; set a few initial cells
    ld      d, 0
    ld      e, 12
    add     de, hl
    ld      [hl], %00111001
    add     de, hl
    ld      [hl], %00111001
    ret


iterate_game::
    call get_current_cell_buffer;   buffer in hl
    ld      c, $FF
    jp      .row_loop_skip
.row_loop

.row_loop_skip
    inc     c
    ld      a, c
    cp      a, CELL_BUFFER_WIDTH
    jp      nz, .row_loop
    ret
