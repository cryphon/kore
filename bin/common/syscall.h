/*
 * syscall.h
 * Description of this file.
 */

#ifndef SYSCALL_H
#define SYSCALL_H

/* --- Includes ------------------------------------------------------------ */

/* --- Macros / Constants -------------------------------------------------- */

/* --- Types / Structs ----------------------------------------------------- */

/* --- Public Function Prototypes ------------------------------------------ */

long syscall(long id, long a0, long a1, long a2);
long sys_write(int fd, char* buf, int len);
long sys_yield();

#endif /* SYSCALL_H */
