# kore

A bare-metal RISC-V operating system kernel, built from scratch as a deep-dive into computer architecture, privilege levels, and OS fundamentals.

> *kore — from the Greek for seed or core. The kernel from which everything grows.*

---

## Overview

**kore** is a minimal OS kernel targeting the **RV32I** instruction set, running on QEMU's `virt` board with no firmware layer (`-bios none`). It implements the full RISC-V privilege hierarchy — machine mode (M), supervisor mode (S), and user mode (U) — from first principles, without relying on OpenSBI or any runtime abstraction.

The project is structured as a staged learning roadmap. Every feature is verified at the hardware level using GDB before moving on, and the codebase is kept intentionally small and readable.

---

## Goals

- Understand RISC-V privilege levels and trap mechanics from the ground up
- Implement a working kernel → user process transition pipeline
- Build syscall infrastructure, timer interrupts, and context switching without any OS library
- Produce a well-documented, GDB-verifiable kernel suitable as a portfolio project and reference

---

## Architecture

```
┌─────────────────────────────────────────┐
│             U-mode (ring 3)             │
│   user processes  │  shell (bin/shell)  │
├─────────────────────────────────────────┤
│             S-mode (ring 1)             │
│  kernel_main  │  trap handler  │  sched │
├─────────────────────────────────────────┤
│             M-mode (ring 0)             │
│       boot.s  │  trap delegation        │
└─────────────────────────────────────────┘
         QEMU virt board — RV32I
         Loaded at 0x80000000, no SBI
```

The boot sequence is:

1. `boot.s` runs in M-mode — sets up PMP, delegates traps via `medeleg`/`mideleg`, drops to S-mode via `mret`
2. `kernel_main` runs in S-mode — initialises UART, wires `stvec`/`sscratch`, launches the first user process
3. User processes run in U-mode — communicate with the kernel via `ecall`

---

## Project Structure

```
kore/
├── boot.s              # M-mode entry point, privilege setup, mret to S-mode
├── kernel/
│   ├── kernel.c        # kernel_main, S-mode init
│   ├── trap.s          # strap_entry / mtrap_entry (assembly trampoline)
│   ├── trap.c          # strap_handler / mtrap_handler (C dispatch)
│   ├── uart.c          # NS16550A UART driver
│   ├── process.c       # Process struct, stack allocation
│   └── log.h           # Tiered logging (LOG_ERROR → LOG_DEBUG)
├── bin/
│   ├── crt0.s          # U-mode startup: umode_entry, exit ecall
│   ├── shell.c         # First user process
│   └── user.h          # U-mode callable declarations
├── linker.ld           # Memory layout: .text (kernel), .utext (user), stacks
├── Makefile
└── docs/
```

---

## Memory Layout

| Region | Address | Description |
|---|---|---|
| Kernel `.text` | `0x80000000` | Boot + kernel code |
| Kernel stack | after `.bss` | 4 KB, grows down |
| Process stack | linker symbol | 4 KB, `__process_stack_start` / `__process_stack_top` |
| User `.utext` | 4 KB-aligned | `crt0.o` + user process code |

---

## Trap Frame

The `TrapFrame` struct (140 bytes) is allocated on the kernel trap stack at every trap entry:

| Offset | Field | Description |
|---|---|---|
| 0–127 | `x1`–`x31` | All general-purpose registers |
| 128 | `sepc` | Saved program counter |
| 132 | `sstatus` | Saved status register |
| 136 | `scause` | Trap cause |

---

## Implemented Features

- [x] **UART driver** — NS16550A, no firmware dependency
- [x] **M-mode boot** — stack setup, PMP, CSR init
- [x] **M → S-mode transition** — via `mret` with `mstatus.MPP = 01`
- [x] **Trap delegation** — `medeleg`/`mideleg = 0xffff` routes all traps to S-mode
- [x] **M-mode trap handler** — `mtrap_entry` / `mtrap_handler` with `mcause` dispatch
- [x] **S-mode trap handler** — `strap_entry` / `strap_handler` with full `TrapFrame` save/restore
- [x] **S → U-mode transition** — via `sret` with `sstatus.SPP = 0`
- [x] **U-mode ecall handling** — `scause = 8` caught, `sepc` advanced, `SYS_EXIT` stub
- [x] **Process struct** — PID, stack pointer; stack allocated via linker script
- [x] **Tiered logging** — compile-time `LOG_LEVEL` flag (`LOG_ERROR` through `LOG_DEBUG`)

---

## Building & Running

**Requirements:**

- `riscv32-unknown-elf-gcc` (bare-metal toolchain)
- `qemu-system-riscv32`
- `gdb-multiarch`

```bash
# Build
make

# Run in QEMU
make qemu

# Debug (open a second terminal after make qemu)
make debug
```

QEMU is started with `-bios none -machine virt -nographic`, loading the kernel ELF at `0x80000000`.

---

## Debugging with GDB

Every feature in this project is verified at the hardware level with GDB before being committed. The workflow:

**Terminal 1** — start QEMU, wait for GDB:
```bash
make qemu   # starts QEMU with -s -S (halts, listens on :1234)
```

**Terminal 2** — attach GDB:
```bash
make debug  # runs gdb-multiarch, connects to :1234, loads symbols
```

Useful commands:
```
(gdb) info registers          # dump all general-purpose registers
(gdb) p/x $scause             # read a CSR value
(gdb) p *frame                # inspect TrapFrame contents
(gdb) x/10i $pc               # disassemble around current PC
(gdb) b strap_handler         # set a breakpoint in the S-mode handler
(gdb) si                      # single-step
```

---

## Development Conventions

- **Commits** follow [Conventional Commits](https://www.conventionalcommits.org/) with GitHub issue references
- **Issues** use a custom template with acceptance criteria, GDB test steps, and expected output
- **Tests** are embedded in `kernel_main` — explicit, traceable, and tied to specific issues
- **Comments** are placed *before* the relevant line, never inline after

---

## Motivation

This project exists to answer a question I kept running into while studying computer science: *what actually happens between the hardware and the OS?* Between the power-on reset vector, the privilege level transitions, the trap handler saving registers to a stack frame, and a user process calling `exit` — there are thousands of small decisions, each one visible and learnable.

kore is my attempt to learn them all, one GDB session at a time.
