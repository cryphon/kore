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
        *(.text)
    } > RAM

    .rodata : {
        *(.rodata)
    } > RAM

    .data : {
        *(.data)
    } > RAM

    .bss : {
        *(.bss)
        *(COMMON)
    } > RAM
}

