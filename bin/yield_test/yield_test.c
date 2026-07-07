/*
 * yield_test.c
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
    int result = sys_write(STDOUT, "Let's YIELD\n", 16);
    sys_yield();
    result = sys_write(STDOUT, "Back from YIELD\n", 16);
    return 0;
}
/* --- Private Functions --------------------------------------------------- */
