INCLUDE "framebuffer.inc"

CELL_BUFFER_WIDTH EQU FRAMEBUFFER_WIDTH
CELL_BUFFER_HEIGHT EQU FRAMEBUFFER_HEIGHT



SECTION "game vars", WRAM0



SECTION "game code", ROM0


init_game::
    ; call get_current_cell_buffer;   buffer in hl

    ; ; set a few initial cells
    ; ld      [hl], %01000000
    ; ld      d, 0
    ; ld      e, 12
    ; add     hl, de
    ; ld      [hl], %00111001
    ; add     hl, de
    ; ld      [hl], %00111001
    ret


iterate_game::
    call    get_cell_buffers     ; buffers in hl, de

    ld      a, %10000000
    ld      [cell_mask], a
    ld      c, $FF
    jp      .row_loop_skip

.row_loop
    ld      b, $FF
    jp      .col_loop_skip

.col_loop
    call get_neighbors

    ; decide successor



;     ; is x > 0?
;     xor     a
;     cp      a, c
;     jp      z, .left

; ; get 0, -1

;     push    hl
;     push    de

;     ld      d, 0
;     ld      e, CELL_BUFFER_ABOVE_OFFSET
;     add     hl, de


;     ld      a, [cell_mask]
;     and     a, hl
;     ; is result zero?
;     jp      nz, .cell_is_set

; .cell_is_set
;     ld,     a, 1

;     ; compare current to next



; .left




.col_loop_skip
    inc     hl
    ld      a, [cell_mask]
    rrca
    ld      [cell_mask], a
    inc     b
    ld      a, b
    cp      a, CELL_BUFFER_WIDTH
    jp      nz, .col_loop


.row_loop_skip
    inc     c
    ld      a, c
    cp      a, CELL_BUFFER_HEIGHT
    jp      nz, .row_loop
    ret
