;*
;* MEMORY.ASM - Memory Manipulation Code
;* by GABY. Inspired by Carsten Sorensen & others.
;*
;* V1.0 - Original release
;*

;If all of these are already defined, don't do it again.

;         IF      !DEF(MEMORY1_ASM)
; MEMORY1_ASM  SET  1

; rev_Check_memory1_asm: MACRO
; ;NOTE: REVISION NUMBER CHANGES MUST BE ADDED
; ;TO SECOND PARAMETER IN FOLLOWING LINE.
;         IF      \1 > 1.0      ; <---- NOTE!!! PUT FILE REVISION NUMBER HERE
;         WARN    "Version \1 or later of 'memory.asm' is required."
;         ENDC
;         ENDM

        INCLUDE "gbhw.inc"
        INCLUDE "memory.inc"

; Macro that pauses until VRAM available.

; lcd_WaitVRAM: MACRO
;         ld      a,[rSTAT]       ; <---+
;         and     STATF_BUSY      ;     |
;         jr      nz,@-4          ; ----+
;         ENDM

;         PUSHS           ; Push the current section onto assember stack.

;         SECTION "Memory1 Code",ROM0



        

SECTION "Memory1 Code",ROM0


;***************************************************************************
;*
;* mem_Set - "Set" a memory region
;*
;* input:
;*    a - value
;*   hl - pMem
;*   bc - bytecount
;*
;***************************************************************************
mem_Set::
    inc	b
    inc	c
    jr	.skip
.loop	ld	[hl+],a
.skip	dec	c
    jr	nz,.loop
    dec	b
    jr	nz,.loop
    ret

;***************************************************************************
;*
;* mem_Copy - "Copy" a memory region
;*
;* input:
;*   hl - pSource
;*   de - pDest
;*   bc - bytecount
;*
;***************************************************************************
mem_Copy::
    inc	b
    inc	c
    jr	.skip
.loop	ld	a,[hl+]
    ld	[de],a
    inc	de
.skip	dec	c
    jr	nz,.loop
    dec	b
    jr	nz,.loop
    ret

;***************************************************************************
;*
;* mem_Copy - "Copy" a monochrome font from ROM to RAM
;*
;* input:
;*   hl - pSource
;*   de - pDest
;*   bc - bytecount of Source
;*
;***************************************************************************
mem_CopyMono::
    inc	b
    inc	c
    jr	.skip
.loop	ld	a,[hl+]
    ld	[de],a
    inc	de
        ld      [de],a
        inc     de
.skip	dec	c
    jr	nz,.loop
    dec	b
    jr	nz,.loop
    ret


;***************************************************************************
;*
;* mem_SetVRAM - "Set" a memory region in VRAM
;*
;* input:
;*    a - value
;*   hl - pMem
;*   bc - bytecount
;*
;***************************************************************************
mem_SetVRAM::
    inc	b
    inc	c
    jr	.skip
.loop
    di
    ld      [hl+],a
    ei
.skip
    dec	c
    jr	nz,.loop
    dec	b
    jr	nz,.loop
    ret

;***************************************************************************
;*
;* mem_CopyVRAM - "Copy" a memory region to or from VRAM
;*
;* input:
;*   hl - pSource
;*   de - pDest
;*   bc - bytecount
;*
;***************************************************************************
mem_CopyVRAM::
    inc	b
    inc	c
    jr	.skip
.loop   di
        ;lcd_WaitVRAM
        ld      a,[hl+]
    ld	[de],a
        ei
    inc	de
.skip	dec	c
    jr	nz,.loop
    dec	b
    jr	nz,.loop
    ret

        ;POPS           ; Pop the current section off of assember stack.

;        ENDC    ;MEMORY1_ASM

