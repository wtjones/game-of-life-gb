INCLUDE "debug.inc"
INCLUDE "framebuffer.inc"
INCLUDE "game.inc"
INCLUDE "cell_buffer.inc"


SECTION "game vars", WRAM0
game_iterations:: DS 1

SECTION "game code", ROM0


; Set initial cells and render to framebuffer
init_game::
    call    clear_framebuffer
    call    init_command_list
    call    init_cell_buffer
    xor     a
    ld      [game_iterations], a

    call    draw_patterns

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

    ; Determine new state of cell: (Wikipedia)
    ; 1. Any live cell with fewer than two live neighbours dies, as if by
    ;    underpopulation.
    ; 2. Any live cell with two or three live neighbours lives on to the next
    ;    generation.
    ; 3. Any live cell with more than three live neighbours dies, as if by
    ;    overpopulation.
    ; 4. Any dead cell with exactly three live neighbours becomes a live cell,
    ;    as if by reproduction.

    ld      a, [current_cell_buffer_iterator_value]
    cp      1
    jr      nz, .skip_is_alive      ; if a == 1
    ld      a, [cell_neighbor_count]
    cp      2
    jr      nz, .skip_is_two            ; if a == 2
    ld      d, 1
    jr      .continue
.skip_is_two                            ; end if
    cp      3
    jr      nz, .skip_lives_on          ; if a == 3
    ld      d, 1
    jr      .continue

.skip_lives_on                          ; end if
    ld      d, 0
    jr      .continue
.skip_is_alive                      ; else is dead
    ld      a, [cell_neighbor_count]
    cp      3
    jr      nz, .skip_reproduce         ; if a == 3
    ld      d, 1
    jr      .continue
.skip_reproduce
    ld      d, 0
                                        ; end if
.continue                           ; end if
    ; d has new cell state


    call    set_cell_buffer_iterator_value

    ld      a, [current_cell_buffer_iterator_value]
    cp      a, d
    jr      z, .skip_draw_cell

    ld      h, d    ; param h = color
    ld      d, b    ; param d = x
    ld      e, c    ; param e = y
    call    get_pixel_addr
    call    push_command_list

.skip_draw_cell
    call    read_joypad
    ld      a, [joypad_state]
    cp      0
    jr      z, .skip_keypress_exit
    ld      a, 0
    ret
.skip_keypress_exit
    call    inc_cell_buffer_iterator

    cp      1
    jp      z, .loop     ; if a = 1

    ld      a, [game_iterations]
    inc     a
    ld      [game_iterations], a
    call    swap_cell_buffers


    DBGMSG "iterate_game end"
    ld      a, 1
    ret
