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
static uint32_t udivmod(uint32_t n, uint32_t d, uint32_t* rem)
{
    if(d == 0)
    {
        if(rem) { *rem = 0; }
        return 0;
    }

    uint32_t quot = 0;
    uint32_t r = 0;

    // iterate over the 32 bits
    for(int i = 31; i >= 0; i--)
    {
        // Shift remainder left by one and brind down next bit of numerator
        r = (r << 1) | ((n >> i) &1U);

        if(r >= d)
        {
            r -= d;
            quot |= (1U << i);
        }
    }
    
    if(rem)
    {
        *rem = r;
    }
    return quot;
}

static inline uint32_t kdiv(uint32_t n, uint32_t d)
{
    return udivmod(n, d, 0); // passed 0 bc remaineder not needed
}

static inline uint32_t kmod(uint32_t n, uint32_t d)
{
    uint32_t rem;
    udivmod(n, d, &rem);
    return rem;
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

size_t uart_write(const char* buf, size_t len)
{ 
    for(size_t i = 0; i < len; i++)
    {
        uart_putc(buf[i]);
    }

    return len;
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
                uint32_t mag = (uint32_t)val;

                if(val < 0) { uart_putc('-'); mag = 0u - mag; }; /* usnigned negate: no UIB, INT_MIN */
                char buf[12];
                int i = 0;
                do { buf[i++] = (char)('0' + kmod(mag, 10)); mag = kdiv(mag, 10); } while (mag);
                for (int j = i - 1; j >= 0; j--) uart_putc(buf[j]);
                break;

            }
            case 'u': {
                unsigned val = va_arg(args, unsigned);
                char buf[12];
                int i = 0;
                do { buf[i++] = (char)('0' + kmod(val, 10)); val = kdiv(val, 10); } while (val);
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
