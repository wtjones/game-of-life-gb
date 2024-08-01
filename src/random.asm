DEF RANDOM_SEED            EQU 10

SECTION "random vars", WRAM0

seed1:: DS 2
seed2:: DS 2

SECTION "random", ROM0

init_random::
    xor a
    ld      a, RANDOM_SEED
    ld      [seed1], a
    ld      [seed1 + 1], a
    ld      [seed2], a
    ld      [seed2 + 1], a
    ret

prng16:
; From https://wikiti.brandonw.net/index.php?title=Z80_Routines:Math:Random
; Inputs:
;   (seed1) contains a 16-bit seed value
;   (seed2) contains a NON-ZERO 16-bit seed value
; Outputs:
;   HL is the result
;   BC is the result of the LCG, so not that great of quality
;   DE is preserved
; Destroys:
;   AF
; cycle: 4,294,901,760 (almost 4.3 billion)
; 160cc
; 26 bytes
    ld      a,[seed1]
    ld      h, a
    ld      a,[seed1 + 1]
    ld      l, a

    ld      b, h
    ld      c, l
    add     hl, hl
    add     hl, hl
    inc     l
    add     hl, bc
    ld      a, h
    ld      [seed1], a
    ld      a, l
    ld      [seed1 + 1], a

    ld      a,[seed2]
    ld      h, a
    ld      a,[seed2 + 1]
    ld      l, a

    add     hl, hl
    sbc     a, a
    and     %00101101
    xor     l
    ld      l, a
    ld      a, h
    ld      [seed2], a
    ld      a, l
    ld      [seed2 + 1], a

    add     hl, bc
    ret

; Loops until a valid random value is found
; Input
;   H = max
;   L = min
; Output
;   A - an 8-bit unsigned integer
; Destroys
;   BC
get_random_range::
.retry
    push    hl
    call    prng16
    ld      a, l
    pop     hl

    cp      a, h        ; carry flag if max > rand
    jr      c, .continue

    cp      a, h
    jr      nz, .retry
.continue
    cp      a, l        ; carry flag if min > rand
    jr      c, .retry
    ret