/*
 * syscall.h
 * Description of this file.
 */

#ifndef SYSCALL_H
#define SYSCALL_H

/* --- Includes ------------------------------------------------------------ */

/* --- Macros / Constants -------------------------------------------------- */

#define SYS_EXIT 93

/* --- Types / Structs ----------------------------------------------------- */

/* --- Public Function Prototypes ------------------------------------------ */

static inline long syscall(long id, long a0, long a1, long a2);
static inline void sys_exit(int code);

#endif /* SYSCALL_H */
