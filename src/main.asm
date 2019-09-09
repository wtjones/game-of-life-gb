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
    ei
    call    init

    ; enable LCD, sprites, bg
    ld      a, LCDCF_ON | LCDCF_BG8000 | LCDCF_OBJON | LCDCF_BGON
    ldh     [rLCDC], a

    ; read mode from make param
    ld      hl, initial_mode
    ld      a, [hl]
    cp      0
    jr      z, .main
    call    test_mode

.main:
    call    init_game
    xor     a
    ld      [game_iterations], a
.main_loop:

    ld      a, [game_iterations]
    cp      a, 0
    jr      nz, .iterated
    call    iterate_game
.iterated
    ;call    swap_cell_buffers
    ; TODO
    call    wait_vblank
    call    apply_command_list
    xor     a
    ld      [command_list_length], a

    jr      .main_loop

draw:
stat:
timer:
serial:
joypad:
    reti

initial_mode:
    DB mode