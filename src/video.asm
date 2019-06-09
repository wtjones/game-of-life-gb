INCLUDE	"gbhw.inc"
INCLUDE "memory.inc"


SECTION "video vars", WRAM0

frame_count:: DS 1
vblank_flag:: DS 1

SECTION "video utility", ROM0

wait_vblank::
    ld      hl, vblank_flag
.wait_vblank_loop
    halt
    nop        ;Hardware bug
    ld      a,$0
    cp      [hl]
    jr      z, .wait_vblank_loop
    ld      [hl], a

    ld      a, [frame_count]
    inc     a
    ld      [frame_count], a
  ret


; Sets the colors to normal palette
init_palette::
    ld     a, %11100100     ; grey 3=11 (Black)
                            ; grey 2=10 (Dark grey)
                            ; grey 1=01 (Light grey)
                            ; grey 0=00 (Transparent)
    ld    [rBGP], a
    ld    [rOBP0], a         ; 48,49 are sprite palettes
                ; set same as background
    ld    [rOBP1], a
    ret


; Calculate an address offset of hl
; Outputs:
; hl = hl + (c * de)
; hl = address in VRAM of start of row
calc_addr::

    ld      c, a
    inc     c
    ;ld      hl, _VRAM
    ;ld      de, $100
    jp      .skip

.loop
    add     hl, de
.skip
    dec     c
    jp      nz, .loop
    ret
