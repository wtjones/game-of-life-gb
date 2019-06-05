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
    xor     a
    ld      [command_list_length], a

    ; test calls
    ld      d, 0
    ld      e, 0
    ld      h, %00000010    
    call get_pixel_addr
    ld      b, d
    ld      c, e
    push    hl
    pop     de
    call push_command_list
   

    ld      d, 127
    ld      e, 0
    ld      h, %00000010
    call get_pixel_addr
    ld      b, d
    ld      c, e
    push    hl
    pop     de
    call push_command_list
   

    ld      d, 0
    ld      e, 127
    ld      h, %00000010
    call get_pixel_addr
    ld      b, d
    ld      c, e
    push    hl
    pop     de
    call push_command_list
   

    ld      d, 127
    ld      e, 127
    ld      h, %00000010
    call get_pixel_addr
    ld      b, d
    ld      c, e
    push    hl
    pop     de
    call push_command_list
   
    ld      d, 121
    ld      e, 121
    ld      h, %00000010
    call get_pixel_addr
    ld      b, d
    ld      c, e
    push    hl
    pop     de
    call push_command_list
   
    call apply_command_list

ret
