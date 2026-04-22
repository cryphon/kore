# trap.s
# RISC-V M-mode trap entry. Saves all registers to a TrapFrame on the kernel stack.

# --- Text Section ----------------------------------------------------------

.section .text
.globl trap_entry
.align 4

trap_entry:
    # 1. swap sp with mscratch to get kernel stack
    # 2. allocate 128 bytes on the stack (addi sp, sp, -128)
    # 3. sw every register to its lot
    # offset for t0 (x1) is 1x4 = 4 so:
    #   sw t0, 4(sp)
    csrrw sp, mscratch, sp      # swap: sp=kernel stack, mscratch=original sp
    addi sp, sp, -128           # allocate trap frame
    sw zero, 0(sp)              # x0 - always zero
    sw x1, 4(sp)                # ra
    # x2 (sp) needs special handling - stored below
    sw x3, 12(sp)               # x3 - gp
    sw x4, 16(sp)               # x4 - tp
    sw x5, 20(sp)               # x5 - t0, save BEFORE clobbering
    csrr t0, mscratch           # t0 now = original sp
    sw t0, 8(sp)                # x2 slot - original sp

    sw x6, 24(sp)               # t1
    sw x7, 28(sp)               # t2
    sw x8, 32(sp)               # s0/fp
    sw x9, 36(sp)               # s1
    sw x10, 40(sp)              # a0
    sw x11, 44(sp)              # a1
    sw x12, 48(sp)              # a2
    sw x13, 52(sp)              # a3
    sw x14, 56(sp)              # a4
    sw x15, 60(sp)              # a5
    sw x16, 64(sp)              # a6
    sw x17, 68(sp)              # a7
    sw x18, 72(sp)              # s2
    sw x19, 76(sp)              # s3
    sw x20, 80(sp)              # s4
    sw x21, 84(sp)              # s5
    sw x22, 88(sp)              # s6
    sw x23, 92(sp)              # s7
    sw x24, 96(sp)              # s8
    sw x25, 100(sp)             # s9
    sw x26, 104(sp)             # s10
    sw x27, 108(sp)             # s11
    sw x28, 112(sp)             # t3
    sw x29, 116(sp)             # t4
    sw x30, 120(sp)             # t5
    sw x31, 124(sp)             # t6
