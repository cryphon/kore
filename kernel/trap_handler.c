/*
 * trap_handler.c
 * Handles traps triggered from e.g. ecalls
 */

/* --- Includes ------------------------------------------------------------ */

#include "trap_handler.h"
#include "uart.h"
#include "csr.h"

/* --- Macros / Constants -------------------------------------------------- */

/* --- Types / Structs ----------------------------------------------------- */

/* --- Private Variables --------------------------------------------------- */

/* --- Private Function Prototypes ----------------------------------------- */

/* --- Public Functions ---------------------------------------------------- */

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

void trap_handler(void)
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
            break;
        case 5:
            uart_puts("Trap: load access fault\n");
            break;
        default:
            uart_puts("Trap: Unknown\n");
            break;
    }
}

/* --- Private Functions --------------------------------------------------- */
