/*
 * yield_test.c
 * Description of this file.
 */

/* --- Includes ------------------------------------------------------------ */
#include "../common/libc.h"
#include "../common/syscall.h"
/* --- Macros / Constants -------------------------------------------------- */

/* --- Types / Structs ----------------------------------------------------- */

/* --- Private Variables --------------------------------------------------- */

/* --- Private Function Prototypes ----------------------------------------- */

/* --- Public Functions ---------------------------------------------------- */
// TODO: rename main_yield back to main after independent links
int main_yield(void)
{
    int result = sys_write(STDOUT, "Hello from yield\n", 16);
    return 0;
}
/* --- Private Functions --------------------------------------------------- */
