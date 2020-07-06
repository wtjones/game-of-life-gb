INCLUDE "debug.inc"
INCLUDE "framebuffer.inc"
INCLUDE "cell_buffer.inc"

SECTION "cell buffer vars", WRAM0

cell_buffer_0: DS CELL_BUFFER_BYTES
cell_buffer_1: DS CELL_BUFFER_BYTES
current_cell_buffer_low: DS 1
current_cell_buffer_high: DS 1
successor_cell_buffer_low: DS 1
successor_cell_buffer_high: DS 1
cell_mask: DS 1

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


; Sets a cell (sets the bit) in the cell buffer
; Input
;   b = x
;   c = y
; Destroys
;   de, hl
set_cell::
    ; move hl to start of row y
    ld      h, 0
    ld      l, c
    add     hl, hl
    add     hl, hl  ; hl = (y * CELL_BUFFER_WIDTH / 8)

    ld      a, [current_cell_buffer_high]
    ld      d, a
    ld      a, [current_cell_buffer_low]
    ld      e, a

    add     hl, de ; hl now points to start of desired row

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
