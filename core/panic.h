/*
 * panic.h
 * Description of this file.
 */

#ifndef PANIC_H
#define PANIC_H

/* --- Includes ------------------------------------------------------------ */

/* --- Macros / Constants -------------------------------------------------- */

/* --- Types / Structs ----------------------------------------------------- */

/* --- Public Function Prototypes ------------------------------------------ */
__attribute__((noreturn)) void kernel_halt(void);
__attribute__((noreturn)) void kernel_panic(const char* msg);

#endif /* PANIC_H */
