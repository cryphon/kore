/*
 * kernel.c
 * Initial entry point of Kernel
 */

/* --- Includes ------------------------------------------------------------ */

#include "uart.h"

/* --- Public Functions ---------------------------------------------------- */

void kernel_main(void)
{
    uart_puts("Hello from kernel\n");
    while(1) { }
}
