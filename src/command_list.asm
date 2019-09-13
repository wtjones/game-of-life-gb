INCLUDE	"gbhw.inc"
INCLUDE "memory.inc"
INCLUDE "debug.inc"

COMMANDS_PER_FRAME_MAX  EQU 12
COMMAND_LIST_MAX        EQU COMMANDS_PER_FRAME_MAX
COMMAND_LIST_SIZE       EQU 8

SECTION "command list vars", WRAM0

command_list_length:: DS 1     ; offset of the next available record
command_list:: DS COMMAND_LIST_MAX * COMMAND_LIST_SIZE
dest_hight:: DS 1
dest_low:: DS 1
push_mask:: DS 1
push_value0:: DS 1
push_value1:: DS 1

SECTION "command list utility", ROM0


init_command_list::
    ld      hl, command_list
    ld      bc, COMMAND_LIST_MAX * COMMAND_LIST_SIZE
    ld      a, $0
    call    mem_Set
    xor     a
    ld      [command_list_length], a
    ret

; Push an operation into the command list
; If the buffer is full, a draw is forced.
;
;Inputs:
; hl = destination
; b = mask
; d = value0
; e = value1
;Destroys:
; BC, HL
push_command_list::
    ld      a, b
    ld      [push_mask], a
    ld      a, d
    ld      [push_value0], a
    ld      a, e
    ld      [push_value1], a

    push    hl
    pop     de      ; move destination to de
    ; determine offset via length * 8
    ld      a, [command_list_length]
    rlca
    rlca
    rlca

    ld      b, 0
    ld      c, a

    ld      hl, command_list
    add     hl, bc

    ; structure:
    ; - dest high
    ; - dest low
    ; - mask
    ; - value0
    ; - value1
    ; - padding
    ; - padding
    ; - padding

    ld      a, d
    ld      [hl+], a
    ld      a, e
    ld      [hl+], a

    ld      a, [push_mask]
    ld      [hl+], a
    ld      a, [push_value0]
    ld      [hl+], a
    ld      a, [push_value1]
    ld      [hl+], a

    ; zero-out padding bytes
    xor     a
    ld      [hl+], a
    ld      [hl+], a
    ld      [hl+], a

    ld      a, [command_list_length]
    inc     a
    ld      [command_list_length], a

    ; If the command buffer is full, wait for blank and draw.
    sub     a, COMMANDS_PER_FRAME_MAX
    jr      z, .list_limit
    ret
.list_limit
    call    wait_vblank
    call    apply_command_list
    ASSERT_NOT_BUSY     ; If the vblank period ended while applying the command
                        ; list, undefined behavior may have occurred.
                        ; The assert will halt the program for debug purposes.
    xor     a
    ld      [command_list_length], a

    ret


apply_command_list::
    ld      hl, command_list
    ld      a, [command_list_length]
    ld      c, a
    ld      b, COMMANDS_PER_FRAME_MAX

    inc     b
    inc	    c
    jr      .skip
.loop

.skip_vblank

    ld      a, [hl+]
    ld      d, a                ; dest high byte
    ld      a, [hl+]
    ld      e, a                ; dest low byte

    ld      a, [hl+]            ; mask
    ld      [push_mask], a
    ld      b, a                ; mask is in b

    ld      a, [hl+]            ; value0
    ld      [push_value0], a
    ld      a, [hl+]            ; value1
    ld      [push_value1], a
    inc     hl
    inc     hl
    inc     hl

    ; use hl to apply operations to the destination
    push    hl
    push    de
    pop     hl

    ld      a, b
    and     a, [hl]             ; apply mask to clear target bit
    ld      [hl], a             ; save result
    ld      a, [push_value0]
    or      a, [hl]             ; set color
    ld      [hl], a             ; save result
    inc     hl

    ld      a, b
    and     a, [hl]             ; apply mask to clear target bit
    ld      [hl], a             ; save result
    ld      a, [push_value1]
    or      a, [hl]             ; set color and move to 2nd byte
    ld      [hl], a             ; save result

    pop     hl

.skip
    dec	    c
    jr      nz,.loop
    xor     a
    ld      [command_list_length], a
    ret
