IF      !DEF(TIMING_ASM)
TIMING_ASM     SET  1

; Delay execution by calling halt \1 times
; Usage example
;   DELAY 10
; Destroys
;   c
DELAY: MACRO
    ld      c, \1
.loop\@
    halt
    dec c
    jr      nz, .loop\@
    ENDM
ENDC
