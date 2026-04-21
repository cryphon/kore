/* linker.ld - Memory layout for RISC-V OS */

MEMORY {
  /* QEMU virt board RAM: 128MB starting at 0x80000000 */
  RAM : ORIGIN = 0x80200000, LENGTH = 128M
}

SECTIONS {
    . = 0x80000000;

    .text : {
        *(.text)
    } > RAM

    .data : {
        *(.data)
    } > RAM

    .bss : {
        *(.bss)
        *(COMMON)
    } > RAM

    . = ALIGN(16);

    /* Reserve 16 KiB for the stack */
    _stack_bottom = .;
    . += 0x4000;
    _stack_top = .;         /* stack grows DOWN from here */
}
