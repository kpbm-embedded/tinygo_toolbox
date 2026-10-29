/* WeAct BlackPill STM32F411CEU6: 512 KB flash, 128 KB RAM (the stm32f4disco/F407 script says 1 MB). */
MEMORY
{
    FLASH_TEXT (rw) : ORIGIN = 0x08000000, LENGTH = 512K
    RAM (xrw)       : ORIGIN = 0x20000000, LENGTH = 128K
}

_stack_size = 4K;

INCLUDE "targets/arm.ld"
