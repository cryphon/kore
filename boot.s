# ============================================================
# boot.s - M-mode boot code
# ============================================================

# boot.s - RISC-V M-mode boot code
# CPU starts here at 0x80000000

.section .text
.globl _start

_start:
    # ========================================
    # Stack Setup
    # ========================================
    # Load address of _stack_top into sp (stack pointer)
    # _stack_top is defined in linker script
    
    lui sp, %hi(_stack_top)
    addi sp, sp, %lo(_stack_top)
    
    # ========================================
    # Infinite loop (for now)
    # ========================================
    # Just spin here. No interrupts, no traps yet.
    
loop:
    jal x0, loop

