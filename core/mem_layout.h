/*
 * mem_layout.h
 * Description of this file.
 */

#ifndef MEM_LAYOUT_H
#define MEM_LAYOUT_H

/* --- Includes ------------------------------------------------------------ */

/* --- Macros / Constants -------------------------------------------------- */
#define PROCESS_STACK_SIZE  0x1000
#define MAX_PROCESSES       4

// Slot size is independed from process stack size, they are currently
// the same however slot size constant will; in the future be expected to 
// both grow statically at first, then become variable
#define SLOT_SIZE_CONSTANT  0x1000

// This is 1MiB into RAM, enough headroom for kernel for now
#define USER_SLOT_BASE 0x80100000

/* --- Types / Structs ----------------------------------------------------- */

/* --- Public Function Prototypes ------------------------------------------ */

#endif /* MEM_LAYOUT_H */
