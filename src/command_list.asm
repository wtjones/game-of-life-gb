INCLUDE	"gbhw.inc"
INCLUDE "memory.inc"

COMMAND_LIST_MAX       EQU 50
COMMAND_LIST_SIZE      EQU 4

SECTION "command list vars", WRAM0

command_list_length:: DS 1     ; offset of the next available record
command_list:: DS COMMAND_LIST_MAX * COMMAND_LIST_SIZE

SECTION "command list utility", ROM0


; Push an operation into the command list
;
;Inputs:
; de = destination
; b = mask0
; c = mask1
;Destroys:
; BC, HL
push_command_list::
    ; determine offset via length * 4
    ld      a, [command_list_length]

    rlca
    rlca

    push    bc
    ld      b, 0
    ld      c, a

    ld      hl, command_list
    add     hl, bc
    pop     bc

    ; structure:
    ; - dest high
    ; - dest low
    ; - mask0
    ; - mask1

    ld      a, d
    ld      [hl+], a
    ld      a, e
    ld      [hl+], a
    ld      a, b
    ld      [hl+], a
    ld      a, c
    ld      [hl], a

    ld      a, [command_list_length]
    inc     a
    ld      [command_list_length], a

    ret


apply_command_list::

    ld      hl, command_list
    ld      a, [command_list_length]
    ld      c, a

    inc	    c
    jr      .skip
.loop    
    ld      a, [hl+]
    ld      d, a        ; dest high byte
    ld      a, [hl+]
    ld      e, a        ; dest low byte
    
    ld      a, [hl+]    ; mask0
    ld      b, a
    ld      a, [de]     ; get the current value
    or      a, b        ; apply mask
    ld      [de], a
    
    ld      a, [hl+]    ; mask1
    ld      b, a
    ld      a, [de]     ; get the current value
    or      a, b        ; apply mask
    ld      [de], a
        
.skip
    dec	    c
    jr      nz,.loop
    ret
