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
    int pid = {0};
    // TODO: no bounds checking yet on pid in proc_init
    proc_init(pid, (void*)__process_stack_pool_start + PROCESS_STACK_SIZE, (void*)0x80100000);
    log_info("Hello from kernel\n"); 

    proc_init(++pid, (void*)__process_stack_pool_start + (2 * PROCESS_STACK_SIZE), (void*)0x80101000);
    /* Jump to U-mode */
    switch_to_umode((uint32_t)tasks[0]->entry_ptr, tasks[0]);    
    while(1) { }
}
