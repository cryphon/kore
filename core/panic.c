/*
 * panic.c
 * Description of this file.
 */

/* --- Includes ------------------------------------------------------------ */
#include "panic.h"
#include "log.h"

/* --- Macros / Constants -------------------------------------------------- */

/* --- Types / Structs ----------------------------------------------------- */

/* --- Private Variables --------------------------------------------------- */

/* --- Private Function Prototypes ----------------------------------------- */

/* --- Public Functions ---------------------------------------------------- */

__attribute__((noreturn)) void kernel_halt(void)
{
    log_info("Kernel: halting\n");
    for (;;) {
        asm volatile("wfi");
    }
}

__attribute__((noreturn)) void kernel_panic(const char* msg)
{
    log_error("PANIC: %s\n", msg);
    kernel_halt();
}
/* --- Private Functions --------------------------------------------------- */
