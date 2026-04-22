# ============================================================
# boot.s - M-mode boot code
# ============================================================

# boot.s - RISC-V M-mode boot code
# CPU starts here at 0x80000000

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
    # Set up mscratch with kernel stack for trap handler
    la t0, __stack_top
    csrw mscratch, t0

    call kernel_main   # stay in M-mode, call directly

hang:
    j hang


