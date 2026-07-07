/*
 * syscall.c
 * Description of this file.
 */

/* --- Includes ------------------------------------------------------------ */
#include "syscall.h"
#include "syscall_nr.h"

/* --- Macros / Constants -------------------------------------------------- */

/* --- Types / Structs ----------------------------------------------------- */

/* --- Private Variables --------------------------------------------------- */

/* --- Private Function Prototypes ----------------------------------------- */

/* --- Public Functions ---------------------------------------------------- */
long syscall(long id, long a0, long a1, long a2) 
{
    register long _id  asm("a7") = id;
    register long _a0  asm("a0") = a0;
    register long _a1  asm("a1") = a1;
    register long _a2  asm("a2") = a2;
    asm volatile("ecall" : "+r"(_a0) : "r"(_id), "r"(_a1), "r"(_a2) : "memory");
    return _a0;
}

long sys_write(int fd, char* buf, int len)
{
    long result = {0};
    result = syscall(SYS_WRITE, fd, (long)buf, len);
    return result;
}
    
long sys_yield()
{
    long result = {0};
    result = syscall(SYS_YIELD, 0, 0, 0);
    return result;
}

/* --- Private Functions --------------------------------------------------- */
