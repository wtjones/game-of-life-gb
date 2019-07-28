INCLUDE "framebuffer.inc"

CELL_BUFFER_WIDTH   EQU FRAMEBUFFER_WIDTH
CELL_BUFFER_HEIGHT  EQU FRAMEBUFFER_HEIGHT
CELL_BUFFER_BYTES   EQU FRAMEBUFFER_WIDTH * FRAMEBUFFER_HEIGHT / 8  ; one bit
                                                                    ; per cell
CELL_BUFFER_ABOVE_OFFSET EQU -FRAMEBUFFER_WIDTH / 8

SECTION "cell buffer vars", WRAM0

cell_buffer_0: DS CELL_BUFFER_BYTES
cell_buffer_1: DS CELL_BUFFER_BYTES
current_cell_buffer: DS 2
successor_cell_buffer: DS 2
cell_mask:: DS 1
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

    ld      hl, current_cell_buffer
    ld      de, cell_buffer_1
    ld      a, d
    ld      [hl+], a
    ld      a, e
    ld      [hl], a

    ld      hl, successor_cell_buffer
    ld      de, cell_buffer_0
    ld      a, d
    ld      [hl+], a
    ld      a, e
    ld      [hl], a

    ret

swap_cell_buffers::
    ; TODO
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
    ld      hl, successor_cell_buffer
    ld      a, [hl+]
    ld      d, a
    ld      a, [hl]
    ld      e, a
    push    de

    ld      hl, current_cell_buffer
    ld      a, [hl+]
    ld      d, a
    ld      a, [hl]
    ld      e, a
    push    de
    pop     hl
    pop     de

    ret



; Inputs
;   hl = current buffer
;   b = x
;   c = y
; Outputs
;   d = active cells
get_neighbors::

    push    hl
    call    get_cell_above
    ld      [cell_neighbor_count], a
    pop     hl

    ld      a, [cell_neighbor_count]
    ld      d, a
    ret

; Inputs
;   hl = current buffer
;   b = x
;   c = y
; Outputs
;   d = active cells
get_cell_above:

; is x > 0?
    xor     a
    cp      a, c
    jp      z, .cell_not_set

; get 0, -1

    ld      d, 0
    ld      e, CELL_BUFFER_ABOVE_OFFSET
    add     hl, de


    ld      a, [cell_mask]
    and     a, [hl]
    ; is result zero?
    jp      nz, .cell_is_set

.cell_not_set
    ld      d, 0
    ret
.cell_is_set
    ld      d, 1
.skip
    ret



; Writes to the successor buffer
; Inputs
;   b = x
;   c = y
;   d = value
set_cell::
    ld      hl, successor_cell_buffer
    ld      a, [hl+]
    ld      d, a
    ld      a, [hl]
    ld      l, a
    ld      h, d

    ld      de, CELL_BUFFER_WIDTH / 8

    CALC_ADDR   ; hl = buffer + (y * CELL_BUFFER_WIDTH / 8)
                ; hl now points to start of desired row

    ;

    ret
