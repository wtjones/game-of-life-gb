INCLUDE "debug.inc"
INCLUDE "framebuffer.inc"

CELL_BUFFER_WIDTH EQU FRAMEBUFFER_WIDTH
CELL_BUFFER_HEIGHT EQU FRAMEBUFFER_HEIGHT


SECTION "game vars", WRAM0
game_iterations:: DS 1

SECTION "game code", ROM0


init_game::
    DBGMSG "init"
    xor a
    ld      [game_iterations], a
    call    get_cell_buffers
    push    hl
    push    de
    pop     hl
    pop     de
    ; set a few initial cells
    ld      [hl], %10000001
    inc     hl
    ld      [hl], %01000010
    inc     hl

    ld      [hl], %10000001
    inc     hl
    ld      [hl], %01000010
    inc     hl

    inc     hl
    inc     hl
    inc     hl
    inc     hl
    inc     hl
    inc     hl
    inc     hl
    inc     hl
    inc     hl
    inc     hl
    inc     hl
    inc     hl
    inc     hl
    inc     hl
    ld      [hl], %10000001
    inc     hl
    ld      [hl], %01000010

    ; ld      d, 0
    ; ld      e, 12
    ; add     hl, de
    ; ld      [hl], %00111001
    ; add     hl, de
    ; ld      [hl], %00111001
    ;call    get_cell_buffers     ; buffers in hl, de
    ret


iterate_game::
    DBGMSG "iterate_game"

    ; ld      d, 7
    ; ld      e, 7
    ; ld      h, 1
    ; call    get_pixel_addr
    ; call    push_command_list
    ; ret

    call    get_cell_buffers     ; buffers in hl, de
    ;call    init_neighbor_count_buffer

    ld      a, %10000000
    ld      [cell_mask], a
    DBGMSG "iterate..."
    ld      c, $FF
    jp      .row_loop_skip

.row_loop
    DBGMSG "row loop"


    ; push    bc
    ; push    hl
    ; ld      d, 0
    ; ld      e, c
    ; ld      h, 1

    ; call    get_pixel_addr
    ; call    push_command_list
    ; pop     hl
    ; pop     bc

    ; update count buffer
    ;call    add_cells

    ld      b, $FF
    jp      .col_loop_skip

.col_loop

    ; read the cell state
    ld      a, [cell_mask]
    and     a, [hl]
    ; is result zero?
    jp      z, .cell_not_set
    DBGMSG "cell set"


    push    bc
    push    hl
    ld      d, 6
    ld      e, c
    ld      h, 1

    call    get_pixel_addr
    call    push_command_list
    pop     hl
    pop     bc

    ld      a, 1
    jp      .continue
.cell_not_set
    DBGMSG "cell not set"
    ld      a, 0

.continue


    ; push hl
    ; push de
    ; ;call get_neighbors
    ; pop de
    ; pop hl


;     ; compare current to next

    ; rotate mask
    ld      a, [cell_mask]
    rrca
    ld      [cell_mask], a
    ; did it wrap?
    cp      a, 1
    ;DBGMSG "mask wrapped"
    jp      nz, .did_not_wrap
    inc     hl ; move to next byte of cell buffer

.did_not_wrap



.col_loop_skip

    inc     b                       ; inc x
    ld      a, b
    cp      a, CELL_BUFFER_WIDTH
    jp      nz, .col_loop
    ;DBGMSG "end of row"

.row_loop_skip
    ;ld      b, 0                     ; reset x
    inc     c
    ld      a, c
    cp      a, CELL_BUFFER_HEIGHT
    jp      nz, .row_loop
    ld      a, [game_iterations]
    inc     a
    ld      [game_iterations], a
    ret
