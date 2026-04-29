# boot.s
# RISC-V M-mode boot code. CPU starts here at 0x80000000.
 
# --- Text Section ----------------------------------------------------------
 
.section .text
.globl _start
_start:
    # global pointer
    la gp, __global_pointer$
    # Stack
    la sp, __stack_top
    # Zero BSS
    la t0, __bss_start
    la t1, __bss_end
bss_loop:
    beq t0, t1, bss_done
    sw zero, 0(t0)
    addi t0, t0, 4
    j bss_loop
bss_done:
    # Point mtvec to trap_entry so traps are handled
    la t0, trap_entry
    csrw mtvec, t0

    # Store kernel stack address in mscratch for use by trap_entry on trap
    la t0, __stack_top
    csrw mscratch, t0

    # Configure PMP - allow S-Mode to access all memory
    li t0, 0x1f
    csrw pmpcfg0, t0
    li t0, 0x3fffffff
    csrw pmpaddr0, t0

    # Set MPP=01 (S-Mode), set mepc to kernel_main, mret
    li t0, (1 << 11)
    csrw mstatus, t0
    la t0, kernel_main
    csrw mepc, t0
    mret

hang:
    j hang
