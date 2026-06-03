/*
 * trap_handler.h
 * Trap entries
 */

#ifndef TRAP_HANDLER_H
#define TRAP_HANDLER_H

/* --- Includes ------------------------------------------------------------ */
#include "trap_types.h"

/* --- Types / Structs ----------------------------------------------------- */

/* --- Public Function Prototypes ------------------------------------------ */
void mtrap_handler(void);
void strap_handler(TrapFrame* frame);

#endif /* TRAP_HANDLER_H */
