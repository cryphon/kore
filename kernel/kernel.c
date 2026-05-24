/*
 * kernel.c
 * Initial entry point of Kernel
 */

/* --- Includes ------------------------------------------------------------ */
#include <stdint.h>
#include "log.h"
#include "proc.h"

/* --- Public Functions ---------------------------------------------------- */
extern char __process_stack_start[];
extern char __process_stack_top[];


/* kernel/kernel.c */

static void test_process_init(void) {
    log_info("=== Testing process initialization ===");
    
    extern Proc init_task;
    
    if (init_task.pid == 1) {
        log_info("Process PID initialized");
    } else {
        log_error("Process PID not set");
    }
    
    uint32_t sp = (uint32_t)init_task.stack_ptr;
    uint32_t start = (uint32_t)__process_stack_start;
    uint32_t top = (uint32_t)__process_stack_top;
    
    if (sp >= start && sp <= top) {
        log_info("Stack pointer in range");
    } else {
        log_error("Stack pointer out of range");
    }
}

void kernel_main(void) {
    log_info("Hello from kernel\n");
    
    test_process_init();
    
    while(1) { }
}
