/* linker.ld
 * Description of this file.
 */

#include "mem_layout.h"

ENTRY(_ustart)
/* --- Memory Regions ------------------------------------------------------ */
MEMORY {
    RAM (rwx) : ORIGIN = USER_SLOT_BASE + (USER_SLOT_INDEX * USER_SLOT_SIZE), LENGTH = USER_SLOT_SIZE
}
/* --- Sections ------------------------------------------------------------ */


SECTIONS {

    .text : {
        crt0.o(.text)
        syscall.o(.text)
        *(.text)
    } > RAM

    .rodata : {
        crt0.o(.rodata)
        syscall.o(.rodata)
        *(.rodata)
    } > RAM

    .data : {
        crt0.o(.data)
        syscall.o(.data)
        *(.data)
    } > RAM

    .bss : {
        *(.bss)
        *(COMMON)
    } > RAM
}

