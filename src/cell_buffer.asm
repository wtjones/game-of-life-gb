INCLUDE "debug.inc"
INCLUDE "framebuffer.inc"

CELL_BUFFER_WIDTH   EQU FRAMEBUFFER_WIDTH
CELL_BUFFER_HEIGHT  EQU FRAMEBUFFER_HEIGHT
CELL_BUFFER_BYTES   EQU FRAMEBUFFER_WIDTH * FRAMEBUFFER_HEIGHT / 8  ; one bit
                                                                    ; per cell
CELL_BUFFER_ABOVE_OFFSET EQU -FRAMEBUFFER_WIDTH / 8

SECTION "cell buffer vars", WRAM0

cell_buffer_0: DS CELL_BUFFER_BYTES
cell_buffer_1: DS CELL_BUFFER_BYTES
neighbor_count_buffer: DS CELL_BUFFER_WIDTH
current_cell_buffer_low: DS 1
current_cell_buffer_high: DS 1
successor_cell_buffer_low: DS 1
successor_cell_buffer_high: DS 1
current_cell_buffer_iterator_low: DS 1
current_cell_buffer_iterator_high: DS 1
successor_cell_buffer_iterator_low: DS 1
successor_cell_buffer_iterator_high: DS 1
cell_mask:: DS 1
cell_buffer_x:: DS 1
cell_buffer_y:: DS 1
cell_neighbor_count: DS 1

SECTION "cell buffer code", ROM0

init_cell_buffer::
    ld      hl, cell_buffer_0
    ld      bc, CELL_BUFFER_BYTES
    ld      a, $0
    call    mem_Set
    ld      hl, cell_buffer_1
    ld      bc, CELL_BUFFER_BYTES
    ld      a, $0
    call    mem_Set

    ld      hl, cell_buffer_1
    ld      a, l
    ld      [current_cell_buffer_low], a
    ld      a, h
    ld      [current_cell_buffer_high], a

    ld      hl, cell_buffer_0
    ld      a, l
    ld      [successor_cell_buffer_low], a
    ld      a, h
    ld      [successor_cell_buffer_high], a


    ; ld      hl, current_cell_buffer
    ; ld      de, cell_buffer_1
    ; ld      a, d
    ; ld      [hl+], a
    ; ld      a, e
    ; ld      [hl], a

    ; ld      hl, successor_cell_buffer
    ; ld      de, cell_buffer_0
    ; ld      a, d
    ; ld      [hl+], a
    ; ld      a, e
    ; ld      [hl], a

    ret

swap_cell_buffers::
    ld      a, [successor_cell_buffer_high]
    ld      h, a
    ld      a, [current_cell_buffer_high]
    ld      [successor_cell_buffer_high], a
    ld      a, h
    ld      [current_cell_buffer_high], a

    ld      a, [successor_cell_buffer_low]
    ld      h, a
    ld      a, [current_cell_buffer_low]
    ld      [successor_cell_buffer_low], a
    ld      a, h
    ld      [current_cell_buffer_low], a
    ret


; ; Ouputs
; ;   hl = current buffer
; ; Destroys
; ;   de
; get_current_cell_buffer::
;     ld      hl, current_cell_buffer
;     ld      a, [hl+]
;     ld      d, a
;     ld      a, [hl]
;     ld      e, a
;     push    de
;     pop     hl
;     ret

; ; Ouputs
; ;   de = successor buffer
; get_successor_cell_buffer::
;     ld      hl, successor_cell_buffer
;     ld      a, [hl+]
;     ld      d, a
;     ld      a, [hl]
;     ld      e, a

;     ret

; Ouputs
;   hl = current buffer
;   de = successor buffer
get_cell_buffers::
    ld      a, [current_cell_buffer_high]
    ld      h, a
    ld      a, [current_cell_buffer_low]
    ld      l, a
    ld      a, [successor_cell_buffer_high]
    ld      d, a
    ld      a, [successor_cell_buffer_low]
    ld      e, a
    ret

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
    ld      [cell_buffer_x], a
    ld      [cell_buffer_y], a
    ld      a, %10000000
    ld      [cell_mask], a

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


    ; TODO : init count buffer

    ; read the cell state
    ld      a, [cell_mask]
    and     a, [hl]
    ; is result zero?
    jp      z, .cell_not_set
    ld      h, 1
    jp      .continue
.cell_not_set
    ld      h, 0
.continue
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
.reset_x_skip
    ld      [cell_buffer_y], a

    ld      a, [current_cell_buffer_iterator_high]
    ld      h, a
    ld      a, [current_cell_buffer_iterator_low]
    ld      l, a
    ld      a, [successor_cell_buffer_iterator_high]
    ld      d, a
    ld      a, [successor_cell_buffer_iterator_low]
    ld      e, a

    ; rotate mask
    ld      a, [cell_mask]
    rrca
    ld      [cell_mask], a
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

    ; increment y
    ld      a, [cell_buffer_y]
    inc     a
    cp      CELL_BUFFER_HEIGHT
    jp      nz, .reset_y_skip
    ld      a, 0    ; return false - iterator complete
    ret
.reset_y_skip
    ld      [cell_buffer_y], a
    ld      a, 1    ; return true - items remain
    ret


init_neighbor_count_buffer::
    ld      hl, neighbor_count_buffer
    ld      bc, CELL_BUFFER_HEIGHT
    ld      a, $00
    call    mem_Set
    ret

; Inputs
;   hl = start of source cell buffer row
; Destroys
;   de, bc
add_cells::
    ld      de, neighbor_count_buffer
    ld      a, %10000000
    ld      [cell_mask], a
    ld      c, CELL_BUFFER_WIDTH
    inc     c
    jp      .skip
.loop
    ; read the cell state
    ld      a, [cell_mask]
    and     a, [hl]
    ; is result zero?
    jp      nz, .cell_is_set
    ld      b, 0
.cell_is_set
    ld      b, 1
    ; b now has the cell state


    ; perform an add of the cell value to the current buffer record
    ld      a, [de]
    add     a, b
    ld      [de], a

    ; rotate the mask
    ld      a, [cell_mask]
    rrca
    ld      [cell_mask], a
    ; did it wrap?
    cp      a, 1
    ;DBGMSG "mask wrapped"
    jp      nz, .did_not_wrap
    inc     hl ; move to next byte of cell buffer
.did_not_wrap


    inc     de  ; move to next byte in count buffer
.skip
    dec     c
    jp      nz, .loop
    ret

; Input
;   b = x
;   c = y
; Destroys
;   de, hl
set_cell::
    call    get_cell_buffers

    ld      de, CELL_BUFFER_WIDTH / 8
    push    bc
    CALC_ADDR   ; hl = buffer + (y * CELL_BUFFER_WIDTH / 8)
                ; hl now points to start of desired row
    pop     bc

    ld      a, b
    sra     a
    sra     a
    sra     a
    sla     a
    sla     a
    sla     a
    ;sub     a, b    ; a = x offset aligned to byte

    ld      e, a
    ld      a, b
    sub     a, e    ; a = x offset aligned to byte


    ld      e, a
    ;  subtract 7 from the x offset to determine # of shifts
    ld      a, 7
    sub     e
    ld      c, a
    inc     c

    ld      b, %00000001
    jp      .skip
.loop
    sla     b

.skip
    dec     c
    jp      nz, .loop

    ; invert mask
    ; ld      a, b
    ; cpl
    ; ld      b, a
    ld      a, b
    or      a, [hl]
    ld      [hl], a


    ret
