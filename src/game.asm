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


; Perform one generaton
iterate_game::
    DBGMSG "iterate_game"

    call    init_cell_buffer_iterator
.loop
    ; iterator sets the following:
    ;   h = current cell value





    ; just invert the value as a test
    ;ld      a, [cell_buffer_x]
    ld      d, b
    ;ld      a, [cell_buffer_y]
    ld      e, c
    ld      h, 1
    call    get_pixel_addr
    call    push_command_list

    call    wait_vblank
    call    apply_command_list

    DBGMSG "incrementing iterator"
    call    inc_cell_buffer_iterator

    cp      a
    jp      z, .loop

    ld      a, [game_iterations]
    inc     a
    ld      [game_iterations], a
    call    swap_cell_buffers
    DBGMSG "iterate_game end"
    ret
