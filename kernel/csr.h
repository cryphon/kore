/*
 * csr.h
 * Macros for reading and writing RISC-V CSRs via inline assembly.
 */

/* --- Macros / Constants -------------------------------------------------- */

#define read_csr(reg) ({ \
        uint32_t val; \
        asm volatile("csrr %0, " #reg : "=r"(val)); \
        val; \
})

#define write_csr(reg, val) ({ \
        asm volatile("csrw " #reg ", %0" :: "r"(val)); \
})
