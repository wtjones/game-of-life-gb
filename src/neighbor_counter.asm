INCLUDE "debug.inc"
INCLUDE "framebuffer.inc"
INCLUDE "cell_buffer.inc"

SECTION "cell buffer counter vars", WRAM0

; Each byte of the count buffer maintains a running total of current
; iterated cell, the cell above, and the cell below.
neighbor_count_buffer: DS CELL_BUFFER_WIDTH
neighbor_count_mask: DS 1
cell_neighbor_count: DS 1

SECTION "cell buffer counter code", ROM0

; Sum the cell states of the first two rows. This primes the count buffer
; for the iteration of the first row of the cell buffer.
; Destroys
;   hl, bc
init_neighbor_count_buffer::
    ld      hl, neighbor_count_buffer
    ld      bc, CELL_BUFFER_WIDTH
    ld      a, $00
    call    mem_Set

    ; determine neighbors of first row by totaling first two rows
    call    get_cell_buffers

    push    hl
    ld      b, 1
    call    count_rows
    pop     hl

    ld      d, 0                        ; move hl to 2nd row
    ld      e, CELL_BUFFER_ROW_BYTES
    add     hl, de

    ld      b, 1
    call    count_rows

    ret


; Inputs
;   hl = start of source cell buffer row;
;   b = add operation value (1 or -1)
; Destroys
;   de, bc
count_rows::
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
