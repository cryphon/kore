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

    __asm__ volatile("ecall");

    uart_puts("Returned from trap\n");
    while(1) { }
}
