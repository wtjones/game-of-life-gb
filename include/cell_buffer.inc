IF      !DEF(CELL_BUFFER_ASM)
CELL_BUFFER_ASM     SET  1

INCLUDE "gbhw.inc"
INCLUDE "framebuffer.inc"

CELL_BUFFER_WIDTH       EQU FRAMEBUFFER_WIDTH
CELL_BUFFER_HEIGHT      EQU FRAMEBUFFER_HEIGHT
; one bit per cell
CELL_BUFFER_ROW_BYTES   EQU CELL_BUFFER_WIDTH / 8
CELL_BUFFER_BYTES       EQU CELL_BUFFER_WIDTH * CELL_BUFFER_HEIGHT / 8

ENDC