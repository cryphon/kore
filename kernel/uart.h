/*
 * uart.h
 * Public interface for the UART driver.
 */

#ifndef UART_H
#define UART_H

/* --- Public Function Prototypes ------------------------------------------ */

void uart_putc(char c);
void uart_puts(const char *s);

#endif /* UART_H */
