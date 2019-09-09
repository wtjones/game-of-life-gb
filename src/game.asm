INCLUDE "debug.inc"
INCLUDE "framebuffer.inc"
INCLUDE "game.inc"

CELL_BUFFER_WIDTH EQU FRAMEBUFFER_WIDTH
CELL_BUFFER_HEIGHT EQU FRAMEBUFFER_HEIGHT


SECTION "game vars", WRAM0
game_iterations:: DS 1

SECTION "game code", ROM0


; Set initial cells and render to framebuffer
init_game::
    DBGMSG "init"
    call    init_cell_buffer
    xor     a
    ld      [game_iterations], a
    call    get_cell_buffers

    ld      b, 0
    ld      c, 0
    INIT_CELL

    ld      b, 15
    ld      c, 0
    INIT_CELL

    ld      b, 1
    ld      c, 1
    INIT_CELL

    ld      b, 14
    ld      c, 1
    INIT_CELL

    call swap_cell_buffers      ; initialized cells are now successors

    call    wait_vblank
    call    apply_command_list
    xor     a
    ld      [command_list_length], a
    ret

iterate_game::
    DBGMSG "iterate_game"
    call    init_cell_buffer_iterator

.loop

    call    inc_cell_buffer_iterator
    cp      a
    jp      nz, .loop


    ld      a, [game_iterations]
    inc     a
    ld      [game_iterations], a
    ret
