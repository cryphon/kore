/*
 * kernel.c
 * Initial entry point of Kernel
 */

/* --- Includes ------------------------------------------------------------ */

#include "uart.h"
#include "log.h"

/* --- Public Functions ---------------------------------------------------- */

void kernel_main(void)
{
    log_info("Hello from kernel\n");
    while(1) { }
}
