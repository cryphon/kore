/* linker.ld
 * Memory layout for RISC-V OS on QEMU virt board.
 */

/* --- Memory Regions ------------------------------------------------------ */

MEMORY {
    /* QEMU virt board RAM: 128MB starting at 0x80000000 */
    RAM : ORIGIN = 0x80000000, LENGTH = 128M
}

/* --- Sections ------------------------------------------------------------ */

SECTIONS {
    . = 0x80000000;
    /* Kernel code (M-mode and S-mode) */
    .text : {
        boot.o(.text)
        kernel/trap.o(.text)
        kernel/trap_handler.o(.text)
        kernel/kernel.o(.text)
        kernel/uart.o(.text)
        kernel/proc.o(.text)
    } > RAM
    .data : {
        __global_pointer$ = . + 0x800;
        *(.data)
    } > RAM
    
    .bss : {
        __bss_start = .;
        *(.bss)
        *(COMMON)
        __bss_end = .;
    } > RAM
    
    . = ALIGN(16);
    
    /* Reserve 16 KiB for the kernel stack */
    __stack_bottom = .;
    . += 0x4000;
    __stack_top = .;

    /* Process kernel stacks */
    __process_stack_start = .;
    . += 0x1000;
    __process_stack_top = .;

    /* Align to page boundary before U-mode code */
    . = ALIGN(0x1000);
    __umode_start = .;
    
    /* User-mode code (U-mode runs here) */
    .utext : {
        crt0.o(.text)
        bin/shell.o(.text)
    } > RAM
    
    /* User-mode data */
    .udata : {
        crt0.o(.data)
        bin/shell.o(.data)
    } > RAM
    
    __umode_end = .;
}
