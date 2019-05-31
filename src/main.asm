INCLUDE "gbhw.inc"
INCLUDE "debug.inc"

SECTION	"start",ROM0[$0150]

start::
    nop
    ; init the stack pointer
    di
    ld      sp, $FFF4

    ; enable only vblank interrupts
    ld      a, IEF_VBLANK
    ldh     [rIE], a	; load it to the hardware register

    ; standard inits
    sub     a	;	a = 0
    ldh     [rSTAT], a	; init status

    ldh     [rSCY], a
    ldh     [rSCX], a

    ldh     [rLCDC], a	; init LCD to everything off

    call    init
    ei
    ; enable LCD, sprites, bg
    ld      a, LCDCF_ON | LCDCF_BG8000 | LCDCF_OBJON | LCDCF_BGON
    ldh     [rLCDC], a


.loop:
    call    wait_vblank

    ASSERT_NOT_BUSY     ; If the vblank period ended while applying the command
                        ; list, undefined behavior may have occurred.
                        ; The assert will halt the program for debug purposes.
    jr      .loop

draw:
stat:
timer:
serial:
joypad:
    reti
