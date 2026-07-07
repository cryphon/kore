/* linker.ld
 * Memory layout for RISC-V OS on QEMU virt board.
 * Preprocessed via gcc -E so consts can be shared with C via mem_layout
 */
#include "mem_layout.h"

ENTRY(_start)
/* --- Memory Regions ------------------------------------------------------ */

MEMORY {
    /* QEMU virt board RAM: 128MB starting at 0x80000000 */
    RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 128M
}

/* --- Sections ------------------------------------------------------------ */
SECTIONS {
    . = 0x80000000;
    
    /* Kernel code (M-Mode & S-Mode). Scoped to boot.0 and core/*.0 only -
     * crt.o and bin/*.o are excluded. and fall through to .utext below instead.
     */
    .text : {
        boot.o(.text)
        *(.text)
    } > RAM

    .rodata : {
        boot.o(.rodata)
        *(.rodata)
    } > RAM

    .data : {
        __global_pointer$ = . + 0x800;
        boot.o(.data)
        *(.data)
    } > RAM

    .bss : {
        __bss_start = .;
        *(.bss)
        *(COMMON)
        __bss_end = .;
    } > RAM

    . = ALIGN(16);

    /* reserve 16 KiB for kernel stack */
    __stack_bottom = .;
    . += 0x4000;
    __stack_top = .;

    /* Process kernel stack pool, sized from shared consts instead of
     * a single hardcoded 0x1000 */
     __process_stack_pool_start = .;
     . += (PROCESS_STACK_SIZE * MAX_PROCESSES);
     __process_stack_pool_end = .;

     /* Align to page boundary before U-Mode code */
     . = ALIGN(0x1000);
     __umode_start = .;

     /* U-Mode code. Scoped to crt0.o and bin/*.o only. */
     .utext : {
         *(.utext)
     } > RAM

     .user_shell USER_SLOT_BASE + (0*USER_SLOT_SIZE) : {
         bin/shell/shell_blob.o(.blob_shell)
     } > RAM

     .user_yield_test USER_SLOT_BASE + (1*USER_SLOT_SIZE) : {
         bin/yield_test/yield_test_blob.o(.blob_yield_test)
     } > RAM
     .urodata : {
         *(.urodata)
     } > RAM

     .udata : {
         *(.udata)
     } > RAM
     __umode_end = .;

     . = ALIGN(0x1000);
     __user_slot_base = .;
}
