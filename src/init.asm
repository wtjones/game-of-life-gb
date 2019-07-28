INCLUDE	"gbhw.inc"

START_TILE_SOURCE   EQU $8E00

SECTION "init", ROM0

init::
    ld      hl, _OAMRAM
    ld      bc, 40 * 4
    ld      a, $00
    call    mem_Set

    ld      hl, _VRAM
    ld      bc, 384 * 16
    ld      a, $00
    call    mem_Set

    ld      hl, _SCRN0
    ld      bc, _SCRN1 - _SCRN0
    ld      a, $ff
    call    mem_Set

    call    init_random
    call    init_palette
    call    init_framebuffer
    call    init_cell_buffer

    call    init_command_list
    xor     a
    ld      [frame_count], a

    call    init_game
ret
