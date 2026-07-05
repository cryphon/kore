/*
 * kernel.c
 * Initial entry point of Kernel
 */

/* --- Includes ------------------------------------------------------------ */
#include <stdint.h>
#include "log.h"
#include "proc.h"
#include "mem_layout.h"

/* --- Public Functions ---------------------------------------------------- */
extern char __process_stack_pool_start[];
extern void switch_to_umode(uint32_t entry, void* task);
extern Proc* tasks[];


/* kernel/kernel.c */

void kernel_main(void) {
    extern char umode_entry[];  /* U-mode code starts here */

    // TODO: no bounds checking yet on pid in proc_init
    proc_init(0, (void*)__process_stack_pool_start + PROCESS_STACK_SIZE);
    log_info("Hello from kernel\n"); 

    proc_init(1, (void*)__process_stack_pool_start + (2 * PROCESS_STACK_SIZE));
    /* Jump to U-mode */
    switch_to_umode((uint32_t)umode_entry, tasks[0]);
    
    while(1) { }
}
