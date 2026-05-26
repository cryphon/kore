/*
 * proc.c
 * Description of this file.
 */

/* --- Includes ------------------------------------------------------------ */
#include "proc.h"

/* --- Macros / Constants -------------------------------------------------- */

/* First process struct, declared here, initialized in boot.s */
Proc init_task = {0};

/* --- Types / Structs ----------------------------------------------------- */

/* --- Private Variables --------------------------------------------------- */

/* --- Private Function Prototypes ----------------------------------------- */

/* --- Public Functions ---------------------------------------------------- */

void proc_init(uint32_t pid, void* stack_addr)
{
    init_task.pid = pid;
    init_task.stack_ptr = stack_addr;
}

/* --- Private Functions --------------------------------------------------- */
