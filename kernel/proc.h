/*
 * proc.h
 * Description of this file.
 */

#ifndef PROC_H
#define PROC_H

/* --- Includes ------------------------------------------------------------ */
#include <stdint.h>

/* --- Macros / Constants -------------------------------------------------- */

/* --- Types / Structs ----------------------------------------------------- */

typedef struct
{
    uint32_t pid;
    void* stack_ptr;
} Proc;


/* --- Public Function Prototypes ------------------------------------------ */
void proc_init(uint32_t pid, void* stack_ptr);

#endif /* PROC_H */
