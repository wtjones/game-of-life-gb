INCLUDE "gbhw.inc"

SECTION "joypad vars", WRAM0

joypad_state:: DS 1

SECTION "joypad code", ROM0

; Sets joypad_state
; Destroys
;
read_joypad::
    ld      a, P1F_5
    ld      [rP1], a

    ld      a, [rP1]
    ld      a, [rP1]
    cpl     ; 0 = pressed state, so invert
    and     $0f
    ld      [joypad_state], a
    ret
