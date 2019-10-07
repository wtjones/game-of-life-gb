INCLUDE "debug.inc"
INCLUDE "framebuffer.inc"
INCLUDE "cell_buffer.inc"

SECTION "neighbor counter vars", WRAM0

; Each byte of the count buffer maintains a running total of the column of
; cells consisting of:
; - the current iterated cell
; - the cell above
; - the cell below
neighbor_count_buffer: DS CELL_BUFFER_WIDTH
neighbor_count_mask: DS 1
neighbor_count_iterator_high:: DS 1
neighbor_count_iterator_low:: DS 1
cell_neighbor_count:: DS 1

SECTION "neighbor counter code", ROM0

; Sum the cell states of the first two rows. This primes the count buffer
; for the iteration of the first row of the cell buffer.
; Destroys
;   hl, bc, de
init_neighbor_count_buffer::
    ld      hl, neighbor_count_buffer
    ld      bc, CELL_BUFFER_WIDTH
    ld      a, $00
    call    mem_Set

    ; determine neighbors of first row by totaling first two rows
    call    get_cell_buffers

    push    hl
    ld      b, 1
    call    count_row
    pop     hl

    ld      d, 0                        ; move hl to 2nd row
    ld      e, CELL_BUFFER_ROW_BYTES
    add     hl, de

    ld      b, 1
    call    count_row

    ; prime iterator
    call init_neighbor_count_iterator
    call inc_neighbor_count

    ret

; Update the count buffer by:
;   - Subtracting the cells from row y - 2
;   - Adding the cells of the next row (y + 1)
; Inputs
;   hl = start of source cell buffer row
; Destroys
;   hl, de, bc
inc_neighbor_count_buffer::
    ; reset neighbor count iterator
    call init_neighbor_count_iterator

    ld      hl, neighbor_count_buffer
    ld      a, [current_cell_buffer_iterator_high]
    ld      h, a
    ld      a, [current_cell_buffer_iterator_low]
    ld      l, a

    ; Subtract values of 2nd to last row

    ld      a, [cell_buffer_y]
    cp      1
    jr      z, .skip_count_prior_row   ; if y !== 1
    push    hl
    ;ld      d, 0
    ; perform hl = hl - width
    ld      e, CELL_BUFFER_ROW_BYTES * 2
    ld      a, l
    sub     a, e
    jr      nc, .skip_sub_carry             ;if e > a
    ld      l, a
    ld      a, h
    dec     a
    ld      h, a                                ; h = h - 1
    jr      .continue_sub_carry
.skip_sub_carry                             ; end if
    ld      l, a
.continue_sub_carry
    ld      b, -1                           ; subtract operation
    call    count_row
    pop     hl
.skip_count_prior_row                   ; end if

    ; Add values of next row

    ld      a, [cell_buffer_y]
    cp      CELL_BUFFER_HEIGHT - 1
    jr      z, .skip_count_next_row   ; if y !== last row
    ld      d, 0
    ld      e, CELL_BUFFER_ROW_BYTES
    add     hl, de                          ; move hl to next row
    ld      b, 1                            ; add operation
    call    count_row
.skip_count_next_row                   ; end if
    ret


; Using the count buffer, update cell_neighbor_count based on the current
; cell buffer position.
; Destroys:
;   hl
inc_neighbor_count::
    ld      a, [neighbor_count_iterator_high]
    ld      h, a
    ld      a, [neighbor_count_iterator_low]
    ld      l, a

    ld      a, [hl]
    ld      d, a                        ; d = count

    ; if not at left bounds, add count of column left of current cell
    ld      a, [cell_buffer_x]
    ld      b, a                        ; b = x
    cp      0
    jr      z, .skip_count_prior_byte   ; if x != 0
    dec     hl
    ld      a, [hl]
    add     a, d
    ld      d, a
    inc     hl
.skip_count_prior_byte                  ; end if

    ; if not at right bounds, add count of column right of current cell
    ld      a, b
    cp      CELL_BUFFER_WIDTH - 1
    jr      z, .skip_count_next_byte    ; if x != max
    inc     hl
    ld      a, d
    add     a, [hl]
    ld      [cell_neighbor_count], a        ; update the neighbor count
.skip_count_next_byte                   ; end if
    ld      a, h
    ld      [neighbor_count_iterator_high], a
    ld      a, l
    ld      [neighbor_count_iterator_low], a

    ; if the current cell is set, subtract 1 from the count
    ld      a, [current_cell_buffer_iterator_value]
    cp      1
    jr      nz, .skip_subtract_current  ; if a == 1
    ld      a, [cell_neighbor_count]
    dec     a
    ld      [cell_neighbor_count], a        ; update the neighbor count
.skip_subtract_current                  ; end if
    ret


; Init iteratgor to start of count buffer
init_neighbor_count_iterator:
    ld      hl, neighbor_count_buffer
    ld      a, h
    ld      [neighbor_count_iterator_high], a
    ld      a, l
    ld      [neighbor_count_iterator_low], a
    ret


; Inputs
;   hl = start of source cell buffer row
;   b = add operation value (1 or -1)
; Destroys
;   de, bc
count_row:
    ld      de, neighbor_count_buffer
    ld      a, %10000000
    ld      [neighbor_count_mask], a
    ld      c, CELL_BUFFER_WIDTH
    inc     c
    jp      .skip
.loop
    ; read the cell state
    ld      a, [neighbor_count_mask]
    and     a, [hl]
    ; is the cell set?
    jp      z, .cell_not_set        ; if a == 0
    ld      a, [de]
    add     a, b
    ld      [de], a                 ; de = de + b
.cell_not_set                       ; end if
    ; rotate the mask
    ld      a, [neighbor_count_mask]
    rrca
    ld      [neighbor_count_mask], a
    ; did the mask wrap?
    cp      a, %10000000
    jp      nz, .did_not_wrap       ; if a != $80
    inc     hl                      ;   move to next byte of cell buffer
.did_not_wrap                       ; end if
    inc     de                      ; move to next byte in count buffer
.skip
    dec     c
    jp      nz, .loop
    ret
