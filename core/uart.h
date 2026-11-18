/*
 * uart.h
 * Public interface for the UART driver.
 */

#ifndef UART_H
#define UART_H
#include <stdint.h>
#include <stddef.h>

/* --- Public Function Prototypes ------------------------------------------ */

void uart_putc(char c);
void uart_puts(const char *s);
size_t uart_write(const char* buf, size_t len);
void uart_printf(const char *fmt, ...);
void uart_put_hex(uint32_t val);

#endif /* UART_H */
