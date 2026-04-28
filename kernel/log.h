/*
 * log.h
 * Description of this file.
 */

#ifndef LOG_H
#define LOG_H

/* --- Includes ------------------------------------------------------------ */

#include "uart.h"

/* --- Macros / Constants -------------------------------------------------- */

#define LOG_LEVEL LOG_DEBUG
#define log_error(msg) do { if (LOG_LEVEL >= LOG_ERROR) { uart_puts("[ERROR] "); uart_puts(msg); uart_puts("\n"); } } while(0)
#define log_warn(msg)  do { if (LOG_LEVEL >= LOG_WARN)  { uart_puts("[WARN]  "); uart_puts(msg); uart_puts("\n"); } } while(0)
#define log_info(msg)  do { if (LOG_LEVEL >= LOG_INFO)  { uart_puts("[INFO]  "); uart_puts(msg); uart_puts("\n"); } } while(0)
#define log_debug(msg) do { if (LOG_LEVEL >= LOG_DEBUG) { uart_puts("[DEBUG] "); uart_puts(msg); uart_puts("\n"); } } while(0)

/* --- Types / Structs ----------------------------------------------------- */

typedef enum {
    LOG_ERROR = 0,
    LOG_WARN  = 1,
    LOG_INFO  = 2,
    LOG_DEBUG = 3,
} LogLevel;

/* --- Public Function Prototypes ------------------------------------------ */

#endif /* LOG_H */
