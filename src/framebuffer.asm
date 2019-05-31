INCLUDE	"gbhw.inc"
INCLUDE "memory.inc"


SECTION "framebuffer vars", WRAM0

color_value:: DS 1
pixel_x:: DS 1
pixel_y:: DS 1
tile_x:: DS 1
tile_y:: DS 1
tile_pixel_offset_x:: DS 1 ; number of pixels into tile_x
tile_pixel_offset_y:: DS 1 ; number of pixels into tile_y


SECTION "framebuffer utility", ROM0

; Inputs:
;   hl = address of pixel in tilemap
;   d = mask0
;   e = mask1
set_pixel::
    ld      a, [hl]
    or      a, d
    ld      [hl+], a
    ld      a, [hl]
    or      a, e
    ld      [hl], a
    ret


; Resolution of 128 * 128
; Inputs:
;   d = x value
;   e = y coord
;   h = color value
; Outputs:
;   hl = address of pixel in tilemap
;   d = mask0
;   e = mask1
; Destroys:
;   bc
get_pixel_addr::
    ld      a, h
    ld      [color_value], a
    ld      a, d
    ld      [pixel_x], a
    ld      a, e
    ld      [pixel_y], a

    ; tile_y = pixel_y / 8
    srl     a
    srl     a
    srl     a
    ld      [tile_y], a
    ld      b, a    ; save tile_y

    ; get the local y coordinate in the tile
    sla     a
    sla     a
    sla     a       ; a = y pixel at tile boundary

    ld      c, a
    ld      a, e    ; a = y pixel param
    sub     a, c    ; a = y pixel - tile aligned y pixel
    ld      [tile_pixel_offset_y], a


    ; tile_x = pixel_x / 8
    ld      a, d            ; a = x pixel param
    srl     a
    srl     a
    srl     a
    ld      [tile_x], a
    ld      b, a            ; save tile_x


    ; get the local x coordinate in the tile
    sla     a
    sla     a
    sla     a       ; a = y pixel at tile boundary

    ld      c, a
    ld      a, d    ; a = x pixel param
    sub     a, c
    ld      [tile_pixel_offset_x], a

    ; advance address to the target tile

    ld      hl, _VRAM
    ld      de, 256
    ld      a, [tile_y]
    ld      c, a
    call    calc_addr  ; hl now points to _VRAM + (y * 256)


    ; tile_ptr =  (tile_y << 8) + (tile_x << 3)

    ld      de, 16
    ld      a, [tile_x]
    ld      c, a
    call    calc_addr   ; hl now points to target tile:
                        ; hl = start_of_row + (x * 16)

    ; move hl to the local pixel row of the tile
    ld      a, [tile_pixel_offset_y]
    sla     a
    ld      d, 0
    ld      e, a
    add     hl, de      ; hl = hl + offset_y * 2

    ; create mask to set the bit of the offset pixel
    ld      a, [tile_pixel_offset_x]
    ld      e, a
    ;  subtract 7 from the x offset to determine # of shifts
    ld      a, 7
    sub     e
    ld      c, a
    inc     c
    ld      a, [color_value]
    and     a, %00000001
    ld      d, a
    ld      a, [color_value]
    and     a, %00000010
    ld      e, a
    sla     e
    jp      .skip
.loop
    sla     d
    sla     e
.skip
    dec     c
    jp      nz, .loop

    ret


; Arrange the tiles into a sequential matrix centered in the bg map to create
; a framebuffer
; Destroys:
;   everything
init_framebuffer::
    ld      hl, _SCRN0
    ld      bc, 16
    ld      d, 0      ; tile counter
init_framebuffer_outer_loop
    inc     hl
    inc     hl
    push bc

    ld      bc, 16
init_framebuffer_inner_loop
    ld      a, d
    ld      [hl], a
    inc     a
    ld      d, a
    inc     hl
    dec     bc
    ld      a, b      ; if b or c != 0,
    or      c
    jr      nz, init_framebuffer_inner_loop

    ; advance hl to next row
    push    de
    ld      de, 14
    add     hl, de
    pop     de

    pop     bc
    dec     bc
    ld      a,b     ; if b or c != 0,
    or      c
    jr      nz, init_framebuffer_outer_loop
    ret
