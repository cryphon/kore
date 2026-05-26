/*
 * csr.h
 * Macros for reading and writing RISC-V CSRs via inline assembly.
 */

/* --- Macros / Constants -------------------------------------------------- */

#define read_csr(reg) ({ \
        uint32_t __val; \
        asm volatile("csrr %0, " #reg : "=r"(__val)); \
        __val; \
})

#define write_csr(reg, v) ({ \
        asm volatile("csrw " #reg ", %0" :: "r"(v)); \
})
