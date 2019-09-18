INCLUDE "debug.inc"
INCLUDE "framebuffer.inc"
INCLUDE "game.inc"
INCLUDE "cell_buffer.inc"


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
    ;   b = x
    ;   c = y

    ld      a, [current_cell_buffer_iterator_value]

    cp      1
    jr      z, .is_set  ; if a = 1
    ld      d, 1
    jr      .continue
.is_set
    ld      d, 0
.continue       ; d is now inverse of current cell

    call set_cell_buffer_iterator_value

    ld      h, d
    ld      d, b
    ld      e, c
    call    get_pixel_addr
    call    push_command_list

    call    wait_vblank
    call    apply_command_list

    call    inc_cell_buffer_iterator

    cp      1
    jp      z, .loop     ; if a = 1

    ld      a, [game_iterations]
    inc     a
    ld      [game_iterations], a
    call    swap_cell_buffers
    DBGMSG "iterate_game end"
    ret
