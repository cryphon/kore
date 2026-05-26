/*
 * uart.c
 * UART driver for QEMU virt board (NS16550A compatible).
 */

/* --- Includes ------------------------------------------------------------ */

#include "stdint.h"
#include "uart.h"

/* --- Macros / Constants -------------------------------------------------- */

#define UART_THR (*(volatile uint8_t*)(0x10000000))
#define UART_LSR (*(volatile uint8_t*)(0x10000005))
#define UART_LSR_THRE (1 << 5)  /* transmit holding register empty */

/* --- Types / Structs ----------------------------------------------------- */

/* --- Private Variables --------------------------------------------------- */

/* --- Private Function Prototypes ----------------------------------------- */

/* --- Public Functions ---------------------------------------------------- */

void uart_putc(char c)
{
    while (!(UART_LSR & UART_LSR_THRE));  /* wait until ready */
    UART_THR = c;
}

void uart_puts(const char* s)
{
    while (*s)
    {
        uart_putc(*s++);
    }
}

void uart_put_hex(uint32_t val)
{
    const char* hex = "0123456789abcdef";
    uart_puts("0x");
    for (int i = 7; i >= 0; i--)
    {
        uart_putc(hex[(val >> (i * 4)) & 0xf]);
    }
}

/* --- Private Functions --------------------------------------------------- */
