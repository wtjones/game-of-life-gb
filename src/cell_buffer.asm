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
current_cell_buffer_low: DS 1
current_cell_buffer_high: DS 1
successor_cell_buffer_low: DS 1
successor_cell_buffer_high: DS 1
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


    ; call    get_cell_buffers
    ; push    hl
    ; ld      hl, current_cell_buffer
    ; ld      a, d
    ; ld      [hl+], a
    ; ld      a, e
    ; ld      [hl], a

    ; pop     de
    ; ld      hl, successor_cell_buffer
    ; ld      a, d
    ; ld      [hl+], a
    ; ld      a, e
    ; ld      [hl], a

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
    ld      h, a
    ld      a, [successor_cell_buffer_high]
    ld      d, a
    ld      a, [successor_cell_buffer_low]
    ld      e, a
    ret


    ; ld      hl, successor_cell_buffer
    ; ld      a, [hl+]
    ; ld      d, a
    ; ld      a, [hl]
    ; ld      e, a
    ; push    de

    ; ld      hl, current_cell_buffer
    ; ld      a, [hl+]
    ; ld      d, a
    ; ld      a, [hl]
    ; ld      e, a
    ; push    de
    ; pop     hl
    ; pop     de

    ; ret



; Inputs
;   hl = current buffer
;   b = x
;   c = y
; Outputs
;   d = active cells
get_neighbors::

    push    hl
    call    get_cell_up
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
;   a = active cells
get_cell_up:

; is x > 0?
    xor     a
    cp      a, c
    jp      z, .not_at_boundary
    ld      a, 0
    ret
.not_at_boundary
; get 0, -1
    ld      d, 0
    ld      e, CELL_BUFFER_ABOVE_OFFSET
    add     hl, de

    ld      a, [cell_mask]
    and     a, [hl]
    ; is result zero?
    jp      nz, .cell_is_set
    xor     a
    ret
.cell_is_set
    ld      a, 1
    ret


; Inputs
;   hl = current buffer
;   b = x
;   c = y
; Outputs
;   a = active cells
get_cell_up_left:
; is x > 0?
    xor     a
    cp      a, b
    jp      z, .not_at_top
    ld      a, 0
    ret

.not_at_top
    xor     a
    cp      a, c
    jp      z, .not_at_left
    ld      a, 0
    ret

.not_at_left
; get -1, -1
    ld      d, 0
    ld      e, CELL_BUFFER_ABOVE_OFFSET
    add     hl, de

    ; rotate the mask
    ld      a, [cell_mask]
    rlca
    ; did it wrap?
    cp      a, 1
    jp      nz, .did_not_wrap
    inc     hl      ; move left by one byte

.did_not_wrap

    and     a, [hl]
    ; is result zero?
    jp      nz, .cell_is_set
    xor     a
    ret
.cell_is_set
    ld      a, 1
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
