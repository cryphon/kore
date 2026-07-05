/*
 * trap_handler.c
 * Handles traps triggered from e.g. ecalls
 */

/* --- Includes ------------------------------------------------------------ */

#include "log.h"
#include "syscall_nr.h"
#include "trap_handler.h"
#include "trap_causes.h"
#include "panic.h"
#include "uart.h"
#include "csr.h"

/* --- Macros / Constants -------------------------------------------------- */

/* --- Types / Structs ----------------------------------------------------- */

/* --- Private Variables --------------------------------------------------- */

/* --- Private Function Prototypes ----------------------------------------- */

void uart_print_hex(uint32_t val) 
{
    uart_puts("0x");
    for (int i = 7; i >= 0; i--) 
    {
        uint8_t nibble = (val >> (i * 4)) & 0xF;
        char c = nibble < 10 ? '0' + nibble : 'a' + (nibble - 10);
        uart_putc(c);
    }
}

static void handle_ecall(TrapFrame* frame)
{
    uint32_t syscall_id = frame->x17;   // a7
    uint32_t arg0       = frame->x10;   // a0

    switch(syscall_id)
    {
        case SYS_EXIT:
            log_debug("Trap: SYS_EXIT, code=%d\n", arg0);
            kernel_halt();
            break;
        case SYS_WRITE:
            char* buf = (char*)frame->x11;
            uint32_t len = frame->x12;
            uart_puts(buf);
            log_debug("Trap: SYS_WRITE, code=%d\n", arg0);
            break;
        case SYS_YIELD:
            // voluntary yield
            frame->x10 = 0;
            break;
        default:
            log_warn("Trap: unknown syscall %d\n", syscall_id);
            frame->x10 = -1; // return error to caller
            break;
    }
    
    frame->sepc += 4; // advance past ecall - in one place
}

static void handle_exception(TrapFrame* frame, uint32_t cause)
{
    switch(cause)
    {
        case EXC_ECALL_UMODE:
            handle_ecall(frame);
            break;
        case EXC_ECALL_SMODE:
        case EXC_ECALL_MMODE:
            log_warn("Trap: ecall from S/M-mode (unexpected)\n");
            frame->sepc += 4;
            break;
        case EXC_ILLEGAL_INSTR:
            log_error("Trap: illegal instruction at 0x%x\n", frame->sepc);
            kernel_panic("illegal instrucion");

        case EXC_LOAD_ACCESS_FAULT:
            log_error("Trap: load access fault at 0x%x\n", frame->sepc);
            kernel_panic("load access fault");

        default:
            log_error("Trap: unhandled exception cause=%d\n", cause);
            kernel_panic("unhandled exception");
    }
}

static void handle_interrupt(TrapFrame* frame, uint32_t cause)
{
    switch (cause)
    {
        case INT_SUPERVISOR_TIMER:
            // schedule() will go here
            log_info("Trap: timer interrupt\n");
            break;

        default:
            log_warn("Trap: unhandled interrupt cause=%d\n", cause);
            break;
    }
}

/* --- Public Functions ---------------------------------------------------- */

void mtrap_handler(void)
{
    uint32_t cause = read_csr(mcause);
    uint32_t epc   = read_csr(mepc);
    
    uart_puts("Trap! cause=");
    uart_print_hex(cause);
    uart_puts(" mepc=");
    uart_print_hex(epc);
    uart_puts("\n");

    switch(cause)
    {
        case 8:         // Environment call from U-Mode
        case 9:         // Environment call from S-Mode
        case 11:        // Environment call from M-Mode
            uart_puts("Trap: ecall\n");
            write_csr(mepc,  read_csr(mepc) + 4); // only advance for ecall
            break;
        case 2:
            uart_puts("Trap: illegal instruction\n");
            write_csr(mepc, read_csr(mepc) + 4); // skip faulting instruction
            break;
        case 5:
            uart_puts("Trap: load access fault\n");
            break;
        default:
            uart_puts("Trap: Unknown\n");
            break;
    }
}

void strap_handler(TrapFrame* frame)
{
    uint32_t cause = frame->scause;
    log_debug("Trap! cause=%x sepc=%x\n", cause, frame->sepc);

    if (cause & CAUSE_INTERRUPT_BIT)
    {
        handle_interrupt(frame, cause & ~CAUSE_INTERRUPT_BIT);
    }
    else
    {
        handle_exception(frame, cause);
    }
}


/* --- Private Functions --------------------------------------------------- */
