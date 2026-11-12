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

    /* Ensure stack sizes are multiples of 16 bytes */
    ASSERT((KERNEL_STACK_SIZE & 0xF) == 0, "KERNEL_STACK_SIZE must be 16-byte aligned")
    ASSERT((USER_STACK_SIZE & 0xF) == 0, "USER_STACK_SIZE must be 16-byte aligned")

    /* reserve 16 KiB for bool/idle kernel stack */
    . = ALIGN(0x1000);
    __stack_bottom = .;
    . += 0x4000;
    __stack_top = .;

    /* Guard page between boot stack and user stack pool */
    __guard_boot_to_user = .;
    . += 0x1000;

    /* Process user stack pool */
    . = ALIGN(0x1000);
    __user_stack_pool_start = .;
    . += (USER_STACK_SIZE * MAX_PROCESSES);
    __user_stack_pool_end = .;


    /* Guard page between user stack pool and kernel stack pool */
    . = ALIGN(0x1000);
    __guard_user_to_kernel = .;
    . += 0x1000;

    /* Process kernel stack pool */
    . = ALIGN(0x1000);
    __kernel_stack_pool_start = .;
    . += (KERNEL_STACK_SIZE * MAX_PROCESSES);
    __kernel_stack_pool_end = .;
    
    /* Guard page before U-Mode */
    . = ALIGN(0x1000);
    __guard_kernel_to_umode = .;
    . += 0x1000;
     
     /* Align to page boundary before U-Mode code */
     . = ALIGN(0x1000);
     __umode_start = .;

     /* --- Linker Assertions --- */
     /* 1. Verify order and non-overlapping layout */
     ASSERT(__stack_top <= __guard_boot_to_user, "Boot stack overlaps guard")
     ASSERT(__user_stack_pool_start >= __guard_boot_to_user + 0x1000, "User pool missing guard below")
     ASSERT(__user_stack_pool_end <= __guard_user_to_kernel, "User pool overlaps middle guard")
     ASSERT(__kernel_stack_pool_start >= __guard_user_to_kernel + 0x1000, "Kernel pool missing guard below")
     ASSERT(__kernel_stack_pool_end <= __guard_kernel_to_umode, "Kernel pool overlaps top guard")
     ASSERT(__umode_start >= __guard_kernel_to_umode + 0x1000, "U-Mode code missing guard below")

     /* 2. Verify 16-byte alignment of pool tops (so every slice top is 16-byte aligned) */
     ASSERT((__stack_top & 0xF) == 0, "__stack_top is not 16-byte aligned")
     ASSERT((__user_stack_pool_end & 0xF) == 0, "__user_stack_pool_end is not 16-byte aligned")
     ASSERT((__kernel_stack_pool_end & 0xF) == 0, "__kernel_stack_pool_end is not 16-byte aligned")

     /* 3. Verify page alignment for PTE unmapping of guard pages */
     ASSERT((__guard_boot_to_user & 0xFFF) == 0, "Boot guard is not page-aligned")
     ASSERT((__guard_user_to_kernel & 0xFFF) == 0, "Middle guard is not page-aligned")
     ASSERT((__guard_kernel_to_umode & 0xFFF) == 0, "Top guard is not page-aligned")


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

}
