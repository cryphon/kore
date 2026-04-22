#include "uart.h"

void kernel_main(void)
{
    uart_puts("Hello from kernel\n");
    while(1) { }
}
