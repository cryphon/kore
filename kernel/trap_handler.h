/*
 * trap_handler.h
 * TrapFrame struct layout for saving all RISC-V registers on trap entry.
 */

#ifndef TRAP_H
#define TRAP_H

/* --- Includes ------------------------------------------------------------ */

#include "stdint.h"
#include "uart.h"

/* --- Types / Structs ----------------------------------------------------- */

typedef struct
{
    uint32_t x0;   /* 0   always zero, saved for alignment */
    uint32_t x1;   /* 4   ra                               */
    uint32_t x2;   /* 8   sp                               */
    uint32_t x3;   /* 12  gp                               */
    uint32_t x4;   /* 16  tp                               */
    uint32_t x5;   /* 20  t0                               */
    uint32_t x6;   /* 24  t1                               */
    uint32_t x7;   /* 28  t2                               */
    uint32_t x8;   /* 32  s0/fp                            */
    uint32_t x9;   /* 36  s1                               */
    uint32_t x10;  /* 40  a0                               */
    uint32_t x11;  /* 44  a1                               */
    uint32_t x12;  /* 48  a2                               */
    uint32_t x13;  /* 52  a3                               */
    uint32_t x14;  /* 56  a4                               */
    uint32_t x15;  /* 60  a5                               */
    uint32_t x16;  /* 64  a6                               */
    uint32_t x17;  /* 68  a7                               */
    uint32_t x18;  /* 72  s2                               */
    uint32_t x19;  /* 76  s3                               */
    uint32_t x20;  /* 80  s4                               */
    uint32_t x21;  /* 84  s5                               */
    uint32_t x22;  /* 88  s6                               */
    uint32_t x23;  /* 92  s7                               */
    uint32_t x24;  /* 96  s8                               */
    uint32_t x25;  /* 100 s9                               */
    uint32_t x26;  /* 104 s10                              */
    uint32_t x27;  /* 108 s11                              */
    uint32_t x28;  /* 112 t3                               */
    uint32_t x29;  /* 116 t4                               */
    uint32_t x30;  /* 120 t5                               */
    uint32_t x31;  /* 124 t6                               */
} TrapFrame;

/* --- Public Function Prototypes ------------------------------------------ */

void trap_handler(void);
#endif /* TRAP_H */
