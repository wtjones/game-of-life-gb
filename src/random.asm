RANDOM_SEED            EQU 10

SECTION "random vars", WRAM0

seed:: DS 1

SECTION "random", ROM0

init_random::
    xor a
    ld      a, RANDOM_SEED
    ld      [seed],a
    ret

; Fast RND (from http://www.z80.info/pseudo-random.txt)
;
; An 8-bit pseudo-random number generator,
; using a similar method to the Spectrum ROM,
; - without the overhead of the Spectrum ROM.
;
; R = random number seed
; an integer in the range [1, 256]
;
; R -> (33*R) mod 257
;
; S = R - 1
;
; Output
;   A - an 8-bit unsigned integer
; Destroys:
;   BC
fast_random::
    ld a, [seed]
    ld b, a

    rrca ; multiply by 32
    rrca
    rrca
    xor $1f

    add a, b
    sbc a, 255 ; carry

    ld [seed], a
    ret
