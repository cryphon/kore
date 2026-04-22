#include "stdint.h"
#include "uart.h"

#define UART_THR (*(volatile uint8_t*)(0x10000000))

void uart_putc(char c)
{
    UART_THR = c;
}

void uart_puts(const char* s)
{
    while(*s)
    {
        uart_putc(*s++);
    }
}


