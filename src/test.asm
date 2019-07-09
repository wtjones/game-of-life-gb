INCLUDE "debug.inc"
INCLUDE "framebuffer.inc"

PIXELS_PER_FRAME        EQU 12

SECTION "test mode vars", WRAM0

fill_pixel_x:: DS 1
fill_pixel_y:: DS 1
fill_color:: DS 1

SECTION "test mode utility", ROM0

; Test mode entry
; Inputs:
;   a = mode in 1, 2, 3
test_mode::
    cp      1
    jr      nz, .skip1
    call    flood_fill
.skip1
    cp      2
    jr      nz, .skip2
    call static_pixels
.skip2
    call random_fill
    ret


; fill framebuffer left to right, then down
flood_fill:
    xor     a
    ld      [fill_pixel_x], a
    ld      [fill_pixel_y], a
    ld      a, %00000001
    ld      [fill_color], a

.flood_loop:
    xor     a
    ld      [command_list_length], a

    ld      a, [fill_pixel_y]
    ld      e, a
    ld      a, [fill_pixel_x]
    ld      d, a

    ld      c, PIXELS_PER_FRAME
    inc     c
    jp      .skip

.loop
    push   bc

    ; draw current position
    ld      a, [fill_color]
    ld      h, a
    push    de
    call    get_pixel_addr
    call    push_command_list
    pop     de

    ; increment x
    ;inc     a
    inc     d
    ld      a, d
    cp      a, FRAMEBUFFER_WIDTH
    jr      nz, .skip_reset_x
    ld      d, 0

    ; increment y
    inc     e
    ld      a, e
    cp      FRAMEBUFFER_HEIGHT
    jr      nz, .skip_reset_y
    ; inc color
    ld      a,  [fill_color]
    inc     a
    and     %00000011
    ld      [fill_color], a
    ld      e, 0

.skip_reset_y
    jr      .done

.skip_reset_x

.done
    pop     bc

.skip
    dec     c
    jr      nz, .loop

    ld      a, e
    ld      [fill_pixel_y], a
    ld      a, d
    ld      [fill_pixel_x], a

    call    wait_vblank
    call    apply_command_list
    ASSERT_NOT_BUSY     ; If the vblank period ended while applying the command
                        ; list, undefined behavior may have occurred.
                        ; The assert will halt the program for debug purposes.
    jp      .flood_loop


static_pixels:

.loop:
    xor     a
    ld      [command_list_length], a


    ld      d, 0
    ld      e, 0
    ld      h, %00000001
    call get_pixel_addr
    call push_command_list

    ld      d, 64
    ld      e, 64
    ld      h, %00000010
    call get_pixel_addr
    call push_command_list


    ld      d, 6
    ld      e, 7
    ld      h, %00000010
    call get_pixel_addr
    call push_command_list

    ld      d, 7
    ld      e, 7
    ld      h, %00000011
    call get_pixel_addr
    call push_command_list


    call    wait_vblank
    call    apply_command_list
    ASSERT_NOT_BUSY     ; If the vblank period ended while applying the command
                        ; list, undefined behavior may have occurred.
                        ; The assert will halt the program for debug purposes.
    jp      .loop


; Draw random pixels
random_fill:

.test_loop:
    xor     a
    ld      [command_list_length], a

    ;rand pixels
    ld      c, 1
    inc     c
    jp      .skip
.loop

    push    bc
    call    fast_random
    and     %01111111
    dec     a
    ld      d, a
    call    fast_random
    and     %01111111
    ld      e, a

    ld      h, %00000010
    call get_pixel_addr
    ld      b, d
    ld      c, e
    push    hl
    pop     de
    call push_command_list
    pop     bc
.skip
    dec     c
    jr      nz, .loop

    call    wait_vblank
    call    apply_command_list
    ASSERT_NOT_BUSY     ; If the vblank period ended while applying the command
                        ; list, undefined behavior may have occurred.
                        ; The assert will halt the program for debug purposes.
    jr      .test_loop
