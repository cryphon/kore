/* linker.ld - Memory layout for RISC-V OS */

MEMORY {
  /* QEMU virt board RAM: 128MB starting at 0x80000000*/
  RAM : ORIGIN = 0x80000000, LENGTH = 128M
}

SECTIONS {
    . = 0x80000000;

    .text : {
        *(.text)
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

    /* Reserve 16 KiB for the stack */
    __stack_bottom = .;
    . += 0x4000;
    __stack_top = .;         /* stack grows DOWN from here */
}
