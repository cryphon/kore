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

void trap_handler(void)
{
    uart_puts("Trap fired!\n");

    // Advance past the caller
    uint32_t epc = read_csr(mepc);
    write_csr(mepc, epc + 4);
}

/* --- Private Functions --------------------------------------------------- */
