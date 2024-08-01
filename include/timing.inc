IF      !DEF(TIMING_ASM)
DEF TIMING_ASM = 1

; Delay execution by calling halt \1 times
; Example usage:
;   DELAY 10
; Destroys
;   c
MACRO DELAY
    ld      c, \1
.loop\@
    halt
    dec c
    jr      nz, .loop\@
    ENDM
ENDC
