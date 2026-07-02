/*
 * proc.c
 * Description of this file.
 */

/* --- Includes ------------------------------------------------------------ */
#include "proc.h"
#include "mem_layout.h"
/* --- Macros / Constants -------------------------------------------------- */

static Proc proc_table[MAX_PROCESSES];
Proc* tasks[MAX_PROCESSES];

/* --- Types / Structs ----------------------------------------------------- */

/* --- Private Variables --------------------------------------------------- */

/* --- Private Function Prototypes ----------------------------------------- */

/* --- Public Functions ---------------------------------------------------- */

void proc_init(uint32_t pid, void* stack_addr)
{
    tasks[pid]  = &proc_table[pid];
    tasks[pid]->pid = pid;
    tasks[pid]->stack_ptr = stack_addr;
}

/* --- Private Functions --------------------------------------------------- */
