/*
 * shell.c
 * Description of this file.
 */

/* --- Includes ------------------------------------------------------------ */
#include "../common/syscall.h"
#include "../common/libc.h"
/* --- Macros / Constants -------------------------------------------------- */

/* --- Types / Structs ----------------------------------------------------- */

/* --- Private Variables --------------------------------------------------- */

/* --- Private Function Prototypes ----------------------------------------- */

/* --- Public Functions ---------------------------------------------------- */

int main(void)
{
    int result = sys_write(STDOUT, "Hello world\n", 11);

    return 0;
}


/* --- Private Functions --------------------------------------------------- */
