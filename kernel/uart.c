#include "stdint.h"
#include "uart.h"

#define UART_THR (*(volatile uint8_t*)(0x10000000))
#define UART_LSR (*(volatile uint8_t*)(0x10000005))
#define UART_LSR_THRE (1 << 5)  // transmit holding register empty

void uart_putc(char c)
{
    while (!(UART_LSR & UART_LSR_THRE));  // wait until ready
    UART_THR = c;
}

void uart_puts(const char* s)
{
    while(*s)
    {
        uart_putc(*s++);
    }
}
