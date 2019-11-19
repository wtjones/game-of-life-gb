INCLUDE "debug.inc"
INCLUDE "game.inc"
INCLUDE "cell_buffer.inc"

NUM_PATTERNS        EQU 4
NUM_NOISE_CELLS     EQU 255

SECTION "pattern vars", WRAM0

draw_pattern_x: DS 1
pattern_width: DS 1

SECTION "pattern code", ROM0

; Inputs
;   d = x
;   e = y
; Destroys
;   hl, de
draw_blinker::
    ld      hl, blinker_pattern
    call    draw_pattern
    ret

; Inputs
;   d = x
;   e = y
; Destroys
;   hl, de
draw_glider::
    ld      hl, glider_pattern
    call    draw_pattern
    ret

draw_patterns::
    ld      c, NUM_PATTERNS / 2
    inc     c
    jr      .skip1

.loop1
    push    bc

    ld      h, CELL_BUFFER_WIDTH - 3
    ld      l, 0
    call    get_random_range
    ld      d, a

    ld      h, CELL_BUFFER_HEIGHT - 3
    ld      l, 0
    call    get_random_range
    ld      e, a

    call    draw_blinker

    ld      h, CELL_BUFFER_WIDTH - 3
    ld      l, 0
    call    get_random_range
    ld      d, a

    ld      h, CELL_BUFFER_HEIGHT - 3
    ld      l, 0
    call    get_random_range
    ld      e, a

    call    draw_glider

    pop     bc
.skip1
    dec     c
    jr      nz, .loop1
    ret

; Set a pattern of random cells
draw_noise::
    ld      c, NUM_NOISE_CELLS
    inc     c
    jr      .skip1

.loop1
    push    bc
    push    de
    push    hl

    ld      h, CELL_BUFFER_WIDTH - 1
    ld      l, 0
    call    get_random_range
    ld      d, a

    ld      h, CELL_BUFFER_HEIGHT - 1
    ld      l, 0
    call    get_random_range
    ld      c, a

    ld      b, d
    ld      h, 1
    INIT_CELL

    pop     hl
    pop     de
    pop     bc
.skip1
    dec     c
    jr      nz, .loop1
    ret

; Inputs
;   hl = address of pattern
;   d = x
;   e = y
; Destroys
;   de
draw_pattern:
    ld      a, d
    ld      [draw_pattern_x], a
    ld      a, [hl+]            ; pattern width
    ld      [pattern_width], a
    ld      a, [hl+]            ; pattern height

    ; set outer loop counter to height
    ld      c, a
    inc     c
    jp      .skip_outer_loop

.outer_loop
    ld      a, [draw_pattern_x]
    ld      d, a

    ; set inner loop counter to width
    ld      a, [pattern_width]
    ld      b, a
    inc     b
    jp      .skip_inner_loop

.inner_loop
    push    bc
    push    de
    push    hl
    ld      a, [hl]
    ld      h, a
    ld      b, d
    ld      c, e
    INIT_CELL
    pop     hl
    pop     de
    pop     bc

    inc     hl
    inc     d       ; x++

.skip_inner_loop
    dec     b
    jr      nz, .inner_loop
    inc     e       ; y++
.skip_outer_loop
    dec     c
    jr      nz, .outer_loop
    ret




SECTION "blinker pattern", ROM0
blinker_pattern:
    DB $03
    DB $03
    DB $00, $01, $00
    DB $00, $01, $00
    DB $00, $01, $00

SECTION "glider pattern", ROM0
glider_pattern:
    DB $03
    DB $03
    DB $01, $00, $01
    DB $00, $01, $01
    DB $00, $01, $00
