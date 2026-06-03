/*
 * trap_causes.h
 * Description of this file.
 */

#ifndef TRAP_CAUSES_H
#define TRAP_CAUSES_H

/* --- Includes ------------------------------------------------------------ */

/* --- Macros / Constants -------------------------------------------------- */

#define CAUSE_INTERRUPT_BIT     0x80000000

// Exceptions
#define EXC_ILLEGAL_INSTR       2
#define EXC_LOAD_ACCESS_FAULT   5
#define EXC_ECALL_UMODE         8
#define EXC_ECALL_SMODE         9
#define EXC_ECALL_MMODE         11

// Interrupts (cause & ~INTERRUPT_BIT)
#define INT_SUPERVISOR_TIMER    5
#define INT_SUPERVISOR_EXTERNAL 9
/* --- Types / Structs ----------------------------------------------------- */

/* --- Public Function Prototypes ------------------------------------------ */

#endif /* TRAP_CAUSES_H */
