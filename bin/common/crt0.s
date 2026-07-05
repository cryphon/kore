# crt0.s
# Description of this file.

# --- Macros / Constants ----------------------------------------------------

# --- Data Section ----------------------------------------------------------
.globl umode_entry
.globl exit

# --- Text Section ----------------------------------------------------------

umode_entry:
    call main
    # a0 holds main's return value — pass it to SYS_EXIT
    j exit

exit:
    li a7, 93          # SYS_EXIT syscall number
    ecall
    j exit             # Hang if it returns
