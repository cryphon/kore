# ============================================================
# boot.s - M-mode boot code
# ============================================================

# boot.s - RISC-V M-mode boot code
# CPU starts here at 0x80000000

.section .text
.globl _start

_start:
    # Stack
    la sp, __stack_top
    
    # global pointer
    la gp, __global_pointer$ 
    
    # Zero bbs
    la t0, __bbs_start
    la t1, __bbs_end
bbs_loop:
    beq t0, t1, bbs_done # if t= == t1 we're done
    sw zero, 0(t0) # store 0 at address t0
    addi t0, t0, 4 # advance 4 bytes
bbs_done:
    call kernel_main

hang:
    j hang


