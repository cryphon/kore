# trap.s
# RISC-V M-mode trap entry. Saves all registers to a TrapFrame on the kernel stack.

# --- Macros / Constants ----------------------------------------------------

.section .text
.global mtrap_entry
.global strap_entry
.align 4

# --- Text Section ----------------------------------------------------------

mtrap_entry:
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

    call mtrap_handler          # Call method that handles trap

     # Restore all registers
    lw x1,  4(sp)
    lw x3,  12(sp)
    lw x4,  16(sp)
    lw x5,  20(sp)
    lw x6,  24(sp)
    lw x7,  28(sp)
    lw x8,  32(sp)
    lw x9,  36(sp)
    lw x10, 40(sp)
    lw x11, 44(sp)
    lw x12, 48(sp)
    lw x13, 52(sp)
    lw x14, 56(sp)
    lw x15, 60(sp)
    lw x16, 64(sp)
    lw x17, 68(sp)
    lw x18, 72(sp)
    lw x19, 76(sp)
    lw x20, 80(sp)
    lw x21, 84(sp)
    lw x22, 88(sp)
    lw x23, 92(sp)
    lw x24, 96(sp)
    lw x25, 100(sp)
    lw x26, 104(sp)
    lw x27, 108(sp)
    lw x28, 112(sp)
    lw x29, 116(sp)
    lw x30, 120(sp)
    lw x31, 124(sp)

    # Restore original sp
    lw x2,  8(sp)
    addi sp, sp, 128       # deallocate trap frame
    csrrw sp, mscratch, sp # restore: sp=original sp, mscratch=kernel stack
    mret                   # return to mepc, restore privilege


strap_entry:

    # --- save all registers ---
    # sp is tricky: we need a scratch space before we can use sp
    # sscratch holds kernel stack (pre-loaded at boot)
    csrrw sp, sscratch, sp      # sp = kernel stack
                                # sscratch = interrupted sp (saved for later)

    addi sp, sp, -128           # allocate 32 * 4 = 128 bytes
    # x0  skipped (always zero, nothing to save)
    sw   x1,   4(sp)            # ra
    # x2 (sp) saved below via sscratch
    sw   x3,  12(sp)            # gp
    sw   x4,  16(sp)            # tp
    sw   x5,  20(sp)            # t0
    sw   x6,  24(sp)            # t1
    sw   x7,  28(sp)            # t2
    sw   x8,  32(sp)            # s0/fp
    sw   x9,  36(sp)            # s1
    sw   x10, 40(sp)            # a0
    sw   x11, 44(sp)            # a1
    sw   x12, 48(sp)            # a2
    sw   x13, 52(sp)            # a3
    sw   x14, 56(sp)            # a4
    sw   x15, 60(sp)            # a5
    sw   x16, 64(sp)            # a6
    sw   x17, 68(sp)            # a7
    sw   x18, 72(sp)            # s2
    sw   x19, 76(sp)            # s3
    sw   x20, 80(sp)            # s4
    sw   x21, 84(sp)            # s5
    sw   x22, 88(sp)            # s6
    sw   x23, 92(sp)            # s7
    sw   x24, 96(sp)            # s8
    sw   x25, 100(sp)           # s9
    sw   x26, 104(sp)           # s10
    sw   x27, 108(sp)           # s11
    sw   x28, 112(sp)           # t3
    sw   x29, 116(sp)           # t4
    sw   x30, 120(sp)           # t5
    sw   x31, 124(sp)           # t6

    # save original sp (currently in sscratch)
    csrr t0, sscratch
    sw t0, 8(sp)                # x2 (original sp) into slot 2

    # Call C handler
    # Pass pointer to trap frame as first arg (a0)
    mv a0, sp
    call strap_handler

    # --- Restore all registers ---
    # Restore original sp first (into t0, apply last)
    lw   t0,   8(sp)            # original sp

    lw   x1,   4(sp)
    lw   x3,  12(sp)
    lw   x4,  16(sp)
    lw   x5,  20(sp)
    lw   x6,  24(sp)
    lw   x7,  28(sp)
    lw   x8,  32(sp)
    lw   x9,  36(sp)
    lw   x10, 40(sp)
    lw   x11, 44(sp)
    lw   x12, 48(sp)
    lw   x13, 52(sp)
    lw   x14, 56(sp)
    lw   x15, 60(sp)
    lw   x16, 64(sp)
    lw   x17, 68(sp)
    lw   x18, 72(sp)
    lw   x19, 76(sp)
    lw   x20, 80(sp)
    lw   x21, 84(sp)
    lw   x22, 88(sp)
    lw   x23, 92(sp)
    lw   x24, 96(sp)
    lw   x25, 100(sp)
    lw   x26, 104(sp)
    lw   x27, 108(sp)
    lw   x28, 112(sp)
    lw   x29, 116(sp)
    lw   x30, 120(sp)
    lw   x31, 124(sp)

    # Restore sp last
    addi sp, sp, 128            # deallocate trap frame
    csrrw sp, sscratch, sp      # restore original sp; sscratch = kernel stack again

    sret                        # return to sepc, restore privilege


