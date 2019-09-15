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
current_cell_buffer_iterator_value:: DS 1
successor_cell_buffer_iterator_value:: DS 1
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
    ld      b, 0
    ld      c, 0
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


    call    get_cell_value
    ld      [current_cell_buffer_iterator_value], a

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

    call    get_cell_value
    ld      [current_cell_buffer_iterator_value], a

    ; get cell state of sucessor x/y
    ld      h, d
    ld      l, e
    call    get_cell_value
    ld      [successor_cell_buffer_iterator_value], a

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
    ld      a, [cell_mask]
    and     a, [hl]
    ; is result zero?
    jp      nz, .cell_is_set
    ld      a, 0
    jr      .cell_is_set_continue
.cell_is_set
    ld      a, 1
.cell_is_set_continue
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
    ; b now has the cell state - TODO FIX


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

    ld      a, [cell_mask]
    cpl                         ; invert mask
    and     a, [hl]             ; apply mask to clear target bit
    ld      [hl], a             ; save result
    ld      a, d
    cp      0
    jr      z, .skip            ; if a = 0
    ld      a, [cell_mask]
    or      a, [hl]             ; set value
    ld      [hl], a             ; save result
.skip
    ret


; Sets a cell (sets the bit) in the cell buffer
; Input
;   b = x
;   c = y
; Destroys
;   de, hl
set_cell::
    call    get_cell_buffers

    ; move hl to start of row y
    ld      de, CELL_BUFFER_WIDTH / 8
    push    bc
    CALC_ADDR       ; hl = buffer + (y * CELL_BUFFER_WIDTH / 8)
                    ; hl now points to start of desired row
    pop     bc

    push    bc

    ; move hl to start of byte containing x
    ld      a, b
    sra     a
    sra     a
    sra     a
    ld      c, a    ; c = x / 8
    ld      de, 1
    CALC_ADDR       ; hl = hl + (x / 8)
                    ; hl now points to target tile:
    pop     bc

    ; determine the offset bit position within the target byte by:
    ; 1. rounding x down to align with the byte
    ; 2. subtract original x from rounded x to get offset
    ld      a, b
    sra     a
    sra     a
    sra     a
    sla     a
    sla     a
    sla     a       ; = x aligned to a byte

    ld      e, a
    ld      a, b
    sub     a, e    ; a = x offset aligned to byte

    ; shift the mask based on bit position
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

    ; set the target value with a mask
    ld      a, b
    or      a, [hl]
    ld      [hl], a

    ret
