/*
 * uart.c
 * UART driver for QEMU virt board (NS16550A compatible).
 */

/* --- Includes ------------------------------------------------------------ */

#include "stdint.h"
#include "stdarg.h"
#include "uart.h"

/* --- Macros / Constants -------------------------------------------------- */

#define UART_THR (*(volatile uint8_t*)(0x10000000))
#define UART_LSR (*(volatile uint8_t*)(0x10000005))
#define UART_LSR_THRE (1 << 5)  /* transmit holding register empty */

/* --- Types / Structs ----------------------------------------------------- */

/* --- Private Variables --------------------------------------------------- */

/* --- Private Function Prototypes ----------------------------------------- */
static int kdiv(int a, int b)
{
    int neg = (a < 0) ^ (b < 0);
    unsigned ua = a < 0 ? -a : a;
    unsigned ub = b < 0 ? -b : b;
    unsigned q = 0;
    while (ua >= ub) { ua -= ub; q++; }
    return neg ? -(int)q : (int)q;
}

static int kmod(int a, int b)
{
    int result = a < 0 ? -a : a;
    int ub     = b < 0 ? -b : b;
    while (result >= ub) result -= ub;
    return a < 0 ? -result : result;
}

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

void uart_printf(const char* fmt, ...) 
{
    va_list args;
    va_start(args, fmt);
    while (*fmt) 
    {
        if (*fmt != '%') 
        {
            uart_putc(*fmt++);
            continue;
        }
        fmt++;  // skip '%'
        switch (*fmt++) 
        {
            case 'd': {
                int val = va_arg(args, int);
                if (val < 0) { uart_putc('-'); val = -val; }
                char buf[12];
                int i = 0;
                do { buf[i++] = '0' + kmod(val, 10); val = kdiv(val, 10); } while (val);
                for (int j = i - 1; j >= 0; j--) uart_putc(buf[j]);
                break;
            }
            case 'u': {
                unsigned val = va_arg(args, unsigned);
                char buf[12];
                int i = 0;
                do { buf[i++] = '0' + (int)kmod((int)val, 10); val = (unsigned)kdiv((int)val, 10); } while (val);
                for (int j = i - 1; j >= 0; j--) uart_putc(buf[j]);
                break;
            }
            case 'x': {
                unsigned val = va_arg(args, unsigned);
                uart_puts("0x");
                for (int i = 7; i >= 0; i--)
                    uart_putc("0123456789abcdef"[(val >> (i*4)) & 0xF]);
                break;
            }
            case 's': {
                const char* s = va_arg(args, const char*);
                uart_puts(s ? s : "(null)");
                break;
            }
            case 'c':
                uart_putc((char)va_arg(args, int));
                break;
            case '%':
                uart_putc('%');
                break;
            default:
                uart_putc('?');
                break;
        }
    }
    va_end(args);
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
