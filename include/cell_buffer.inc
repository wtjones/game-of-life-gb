IF      !DEF(CELL_BUFFER_ASM)
CELL_BUFFER_ASM     SET  1

INCLUDE "gbhw.inc"
INCLUDE "framebuffer.inc"

CELL_BUFFER_WIDTH   EQU FRAMEBUFFER_WIDTH
CELL_BUFFER_HEIGHT  EQU FRAMEBUFFER_HEIGHT
CELL_BUFFER_BYTES   EQU FRAMEBUFFER_WIDTH * FRAMEBUFFER_HEIGHT / 8  ; one bit
                                                                    ; per cell
ENDC
