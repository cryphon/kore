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

    while(1) { }
}
