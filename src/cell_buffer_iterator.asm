INCLUDE "debug.inc"
INCLUDE "framebuffer.inc"
INCLUDE "cell_buffer.inc"

SECTION "cell buffer iterator vars", WRAM0

current_cell_buffer_iterator_high:: DS 1
current_cell_buffer_iterator_low:: DS 1
current_cell_buffer_iterator_value:: DS 1
successor_cell_buffer_iterator_high: DS 1
successor_cell_buffer_iterator_low: DS 1
successor_cell_buffer_iterator_value:: DS 1
cell_buffer_iterator_mask: DS 1
cell_buffer_x:: DS 1
cell_buffer_y:: DS 1
cell_neighbor_count: DS 1

SECTION "cell buffer iterator code", ROM0

; Output
;   b = x
;   c = y
;   h = current cell value
;   l = total neighbors
;   a = items remaining boolean
; Destroys
;   de
init_cell_buffer_iterator::
    xor     a
    ld      b, 0
    ld      c, 0
    ld      [cell_buffer_x], a
    ld      [cell_buffer_y], a
    ld      a, %10000000
    ld      [cell_buffer_iterator_mask], a

    ; set buffer pointers to start of buffers
    call    get_cell_buffers
    ld      a, h
    ld      [current_cell_buffer_iterator_high], a
    ld      a, l
    ld      [current_cell_buffer_iterator_low], a
    ld      a, d
    ld      [successor_cell_buffer_iterator_high], a
    ld      a, e
    ld      [successor_cell_buffer_iterator_low], a


    push    hl
    push    bc
    call    init_neighbor_count_buffer
    pop     bc
    pop     hl

    ; prime the current cell value
    call    get_cell_value
    ld      [current_cell_buffer_iterator_value], a

    ; prime the sucessor cell value
    ld      h, d
    ld      l, e
    call    get_cell_value
    ld      [successor_cell_buffer_iterator_value], a

    ld      a, 1
    ret


; Output
;   b = x
;   c = y
;   h = current cell value
;   l = total neighbors
;   a = items remaining boolean
inc_cell_buffer_iterator::

    ; increment x
    ld      a, [cell_buffer_x]
    inc     a
    cp      CELL_BUFFER_WIDTH
    jp      nz, .reset_x_skip
    xor     a
    ld      [cell_buffer_x], a

    ; increment y
    ld      a, [cell_buffer_y]
    inc     a
    cp      CELL_BUFFER_HEIGHT
    jp      nz, .reset_y_skip
    ld      c, a
    DBGMSG "iterator at end"
    ld      a, 0    ; return false - iterator complete
    ret
.reset_y_skip
    ld      [cell_buffer_y], a
    ld      c, a
    jp      .continue
.reset_x_skip
    ld      [cell_buffer_x], a
    ld      b, a

.continue
    ld      a, [current_cell_buffer_iterator_high]
    ld      h, a
    ld      a, [current_cell_buffer_iterator_low]
    ld      l, a
    ld      a, [successor_cell_buffer_iterator_high]
    ld      d, a
    ld      a, [successor_cell_buffer_iterator_low]
    ld      e, a

    ; rotate mask
    ld      a, [cell_buffer_iterator_mask]
    rrca
    ld      [cell_buffer_iterator_mask], a
    ; did it wrap?
    cp      a, %10000000
    ;DBGMSG "mask wrapped"
    jp      nz, .did_not_wrap
    inc     hl ; move to next byte of cell buffer
    inc     de
.did_not_wrap

    ld      a, h
    ld      [current_cell_buffer_iterator_high], a
    ld      a, l
    ld      [current_cell_buffer_iterator_low], a
    ld      a, d
    ld      [successor_cell_buffer_iterator_high], a
    ld      a, e
    ld      [successor_cell_buffer_iterator_low], a

    ; get cell state of current x/y
    call    get_cell_value
    ld      [current_cell_buffer_iterator_value], a

    ; get cell state of sucessor x/y
    ld      h, d
    ld      l, e
    call    get_cell_value
    ld      [successor_cell_buffer_iterator_value], a

    ; if at start of a row, update the count buffer
    ld      a, [cell_buffer_x]
    cp      0
    jr      nz, .skip_count_row         ; if a != 0
    push    hl
    push    bc
    call    inc_neighbor_count_buffer
    pop     bc
    pop     hl
.skip_count_row                         ; end if

    ld      a, [cell_buffer_x]
    ld      b, a
    ld      a, [cell_buffer_y]
    ld      c, a

    ld      a, 1    ; return true - items remain
    ret


; Inputs
;   hl = address of byte in cell buffer
; Outputs
;   a = value
get_cell_value
 ; get cell state of current x/y
    ld      a, [cell_buffer_iterator_mask]
    and     a, [hl]
    ; is result zero?
    jp      nz, .cell_is_set
    ld      a, 0
    jr      .cell_is_set_continue
.cell_is_set
    ld      a, 1
.cell_is_set_continue
ret


; Set the value of the iterated successor cell
; Input
;   d = cell value
; Destroys
;   hl
set_cell_buffer_iterator_value::
    ld      a, [successor_cell_buffer_iterator_high]
    ld      h, a
    ld      a, [successor_cell_buffer_iterator_low]
    ld      l, a

    ld      a, [cell_buffer_iterator_mask]
    cpl                         ; invert mask
    and     a, [hl]             ; apply mask to clear target bit
    ld      [hl], a             ; save result
    ld      a, d
    cp      0
    jr      z, .skip            ; if a = 0
    ld      a, [cell_buffer_iterator_mask]
    or      a, [hl]             ;   set value
    ld      [hl], a             ;   save result
.skip                           ; end if
    ret
