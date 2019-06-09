INCLUDE	"gbhw.inc"

START_TILE_SOURCE   EQU $8E00

SECTION "init", ROM0

init::
    ld      hl, _OAMRAM
    ld      bc, 20 * 4
    ld      a, $00
    call    mem_SetVRAM

    ld      hl, _VRAM
    ld      bc, 256 * 16
    ld      a, $00
    call    mem_SetVRAM

    ld      hl, _SCRN0
    ld      bc, _SCRN1 - _SCRN0
    ld      a, $ff
    call    mem_Set
    call    init_random
    call    init_palette
    call    init_framebuffer

ret
