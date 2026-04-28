/*
 * kernel.c
 * Initial entry point of Kernel
 */

/* --- Includes ------------------------------------------------------------ */

#include "log.h"

/* --- Public Functions ---------------------------------------------------- */

void kernel_main(void)
{
    log_info("Hello from kernel\n");

    __asm__ volatile("ecall");

    log_info("Returned from trap\n");
    while(1) { }
}
