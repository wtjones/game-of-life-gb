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

    call init_framebuffer

    ; test calls
    ld      d, 110
    ld      e, 69
    ld      h, %00000010
    call get_pixel_addr
    call set_pixel

    ld      d, 0
    ld      e, 0
    ld      h, %00000001
    call get_pixel_addr
    call set_pixel

    ld      d, 4
    ld      e, 4
    ld      h, %00000001
    call get_pixel_addr
    call set_pixel

    ld      d, 0
    ld      e, 127
    ld      h, %00000001
    call get_pixel_addr
    call set_pixel

    ld      d, 4
    ld      e, 123
    ld      h, %00000001
    call get_pixel_addr
    call set_pixel

ret
