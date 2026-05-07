/*
 * kernel.c
 * Initial entry point of Kernel
 */

/* --- Includes ------------------------------------------------------------ */

#include "log.h"
#include "csr.h"

/* --- Public Functions ---------------------------------------------------- */

void kernel_main(void)
{
    log_info("Hello from kernel\n");
    log_info("Before trap\n");
    asm volatile("ecall");
    log_info("After trap\n");
    while(1) { }
}
