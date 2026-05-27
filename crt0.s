# crt0.s
# Description of this file.

# --- Macros / Constants ----------------------------------------------------

# --- Data Section ----------------------------------------------------------
.globl umode_entry
.globl exit

# --- Text Section ----------------------------------------------------------

umode_entry:
    call main
    
    # If main() returns, we hang here instead of looping on ecall.
    # 
    # Note: S-mode cannot modify sepc (supervisor exception program counter)
    # directly via csrw - it's read-only in hardware. This means we cannot
    # advance the program counter from the trap handler to skip over the
    # ecall instruction. Therefore, attempting ecall would cause an infinite
    # loop of traps.
    #
    # To properly handle syscalls, we need a different mechanism:
    # - U-mode can pass arguments in a0-a7 and ra
    # - The trap handler inspects scause to determine the syscall type
    # - The kernel performs the syscall and returns to U-mode
    # - But sepc advancement must happen at hardware level or via other means
    #
    # For now, U-mode programs should avoid ecall and instead just return
    # from main() or hang gracefully.
    
    j exit

exit:
    # a0 = exit code
    li a7, 93          # SYS_EXIT syscall number
    ecall
    j exit             # Hang if it returns
