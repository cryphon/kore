# RISC-V OS Learning Project - Complete Roadmap

## Project Name Suggestions

Pick one you like:

1. **`riscv-os-from-scratch`** - Descriptive, clear intent
2. **`rv32-kernel`** - Short, technical
3. **`bare-metal-riscv`** - Emphasizes the bare metal aspect
4. **`riscv-teaching-os`** - Good if you plan to teach others
5. **`minimal-riscv-os`** - Highlights minimalist approach

**Recommendation:** `riscv-os-from-scratch` - clear, searchable, descriptive

---

## Project Structure

```
riscv-os-from-scratch/
├── README.md               # Overview
├── ROADMAP.md             # THIS FILE
├── Makefile               # Build system
├── linker.ld              # Memory layout
│
├── src/
│   ├── boot.s             # M-mode bootstrap
│   ├── kernel.c           # Kernel entry (will add)
│   ├── trap.s             # Trap handler (will add)
│   └── uart.c             # UART driver (will add)
│
├── docs/
│   ├── ARCHITECTURE.md    # High-level design
│   ├── CSR_GUIDE.md       # Control status registers
│   ├── DEBUGGING.md       # GDB tips
│   └── OPENSBI.md         # OpenSBI notes
│
└── tests/
    └── test_commands.sh   # Useful commands
```

---

## Complete Learning Roadmap

Follow these steps in order. **Each is a complete, testable milestone.**

### Phase 1: Foundation (Days 1-2)

---

#### **Step 1.1: Project Setup & Build System**
**Goal:** Can compile and run empty kernel

**Files to create:**
- `Makefile`
- `linker.ld`
- `src/boot.s` (3-4 lines)

**What to verify:**
- `make all` builds without errors
- `make disasm` shows entry at 0x80200000
- `make run` boots to infinite loop (no errors)
- `make debug` + GDB can step through

**Commands to test:**
```bash
make clean && make all
make disasm | head -20
make run  # Ctrl+A then X to exit
make debug  # In GDB: step, info registers, quit
```

**Success criteria:**
- ✓ Kernel loads at 0x80200000
- ✓ Stack pointer set correctly
- ✓ Infinite loop (expected behavior)

**Do NOT move on until:** GDB can step through boot.s and you see the stack pointer register changing

---

#### **Step 1.2: UART Output (Hello World)**
**Goal:** Print "Hello from kernel" to console

**Files to create/modify:**
- `src/uart.c` - UART driver (putchar, puts functions)
- `src/kernel.c` - New kernel entry point
- `Makefile` - Add kernel.c to build
- `linker.ld` - Add sections for data, bss

**What to implement:**
```c
void uart_putchar(char c);  // Write one char
void uart_puts(const char *s);  // Write string
void main_kernel();  // Kernel entry
```

**What to verify:**
- `make all` builds boot.s + kernel.c
- `make run` shows "Hello from kernel"
- Characters print correctly (test with numbers, symbols)

**Success criteria:**
- ✓ See kernel message on boot
- ✓ Can print multiple strings
- ✓ GDB can set breakpoint in kernel.c

**Do NOT move on until:** You see text output in QEMU

---

#### **Step 1.3: Understanding CSRs & Privilege Modes**
**Goal:** Know what CSRs do and why they matter

**Reading:** RISC-V Privileged ISA manual (Chapter 10)
- [ ] Understand mstatus, sstatus (privilege bits)
- [ ] Understand *tvec, *epc, *cause (trap handling)
- [ ] Understand mie, sie (interrupts)

**No code yet.** Just understanding.

**Success criteria:**
- ✓ Can explain what mstatus[11:10] (MPP) does
- ✓ Can explain boot sequence: M-mode → S-mode → U-mode
- ✓ Can explain trap vector: CPU saves state to CSRs, jumps to handler

**Do NOT move on until:** You can draw the boot diagram and explain it

---

### Phase 2: Privilege Modes (Days 3-4)

---

#### **Step 2.1: Switch to S-mode**
**Goal:** Boot in M-mode, then switch to S-mode

**Files to create/modify:**
- `src/boot.s` - Add M-mode setup, switch to S-mode via mret
- `src/kernel.c` - Now runs in S-mode
- `src/kernel.h` - Add CSR read/write functions

**What to implement:**
```c
// Helper macros to read/write CSRs
uint32_t read_csr(uint32_t csr_num);
void write_csr(uint32_t csr_num, uint32_t val);

// In boot.s:
// Set mstatus[11:10] = 01 (S-mode)
// Set mepc to kernel entry
// mret to jump to S-mode
```

**What to verify:**
- Boot code runs in M-mode
- Switches to S-mode via mret
- Kernel runs in S-mode

**Testing in GDB:**
```
(gdb) break main_kernel
(gdb) continue
(gdb) p/x $a0  # or any register
(gdb) # Should show S-mode was entered
```

**Success criteria:**
- ✓ Boot.s properly sets up mstatus
- ✓ mepc points to kernel entry
- ✓ mret successfully switches modes
- ✓ Kernel prints "Running in S-mode"

**Do NOT move on until:** You understand mret's automatic behavior

---

#### **Step 2.2: Set Up Trap Vectors**
**Goal:** Tell CPU where to jump if exception occurs

**Files to create/modify:**
- `src/kernel.c` - Add trap vector setup
- `src/trap.s` - Create (minimal, no actual trap handling yet)
- `src/trap.c` - Handler dispatcher

**What to implement:**
```c
// In kernel:
extern void supervisor_trap_handler();  // Assembly

// Write stvec CSR
write_csr(0x105, (uint32_t)&supervisor_trap_handler);

// In trap.s:
// Just a stub for now - returns immediately
supervisor_trap_handler:
    sret
```

**What to verify:**
- Trap vector is set
- No crashes when enabled

**Success criteria:**
- ✓ stvec is written
- ✓ Code compiles and runs
- ✓ No unexpected traps occur

**Do NOT move on until:** You've read stvec CSR in GDB and verified address

---

### Phase 3: Exception Handling (Days 5-6)

---

#### **Step 3.1: Handle Illegal Instruction**
**Goal:** Trigger an exception and handle it gracefully

**Files to create/modify:**
- `src/trap.c` - Add exception dispatcher
- `src/trap.s` - Save/restore registers, call C handler
- `src/kernel.c` - Intentionally trigger illegal instruction to test

**What to implement:**
```c
// In trap.c:
void handle_trap() {
    uint32_t cause = read_csr(0x142);  // scause
    uint32_t epc = read_csr(0x141);    // sepc
    
    uart_puts("Trap! Cause=");
    uart_puthex(cause);
    uart_puts(" EPC=");
    uart_puthex(epc);
    uart_putchar('\n');
}

// In kernel.c:
// Intentionally execute invalid instruction
asm volatile("unimp");  // Illegal instruction
```

**What to verify:**
- Illegal instruction triggers trap
- Trap handler catches it and prints info
- Program continues (or exits gracefully)

**Success criteria:**
- ✓ See "Trap! Cause=..." message
- ✓ Cause code is 2 (illegal instruction)
- ✓ EPC points to bad instruction

**Do NOT move on until:** You can trigger and handle an exception

---

#### **Step 3.2: Implement Full Trap Save/Restore**
**Goal:** Save all registers on trap, restore them after

**Files to create/modify:**
- `src/trap.s` - Save all 32 registers to stack, restore them

**What to implement:**
```asm
supervisor_trap_handler:
    # Save all registers to stack
    addi sp, sp, -128    # Space for 32 regs * 4 bytes
    sw x1, 0(sp)
    sw x2, 4(sp)
    # ... repeat for all 32 ...
    
    # Call C handler
    jal x1, trap_handler_c
    
    # Restore all registers
    lw x1, 0(sp)
    lw x2, 4(sp)
    # ... repeat for all 32 ...
    addi sp, sp, 128
    
    sret
```

**What to verify:**
- All registers saved/restored correctly
- Handler can read register values
- Program state preserved across trap

**GDB test:**
```
(gdb) break trap_handler_c
(gbc) # Trigger trap
(gdb) info registers
# Should show saved values, not zeros
```

**Success criteria:**
- ✓ Full register state saved
- ✓ Handler can inspect registers
- ✓ Registers restored after trap

**Do NOT move on until:** Register save/restore is bulletproof

---

### Phase 4: User Mode (Days 7-8)

---

#### **Step 4.1: Create User Process**
**Goal:** Load user code in memory, switch to U-mode

**Files to create/modify:**
- `src/process.c` - Process creation, structure
- `src/process.h` - Process definitions
- `src/user_app.c` - Simple user application

**What to implement:**
```c
struct process {
    uint32_t pid;
    uint32_t *stack;
    // ...
};

void create_process(void (*entry)());

// User app
void user_app() {
    uart_puts("Hello from U-mode\n");
    while(1);
}
```

**What to verify:**
- Process structure created
- User app linked as separate binary
- Process stack allocated

**Success criteria:**
- ✓ Can create process struct
- ✓ Can calculate entry point
- ✓ Stack is allocated (doesn't crash)

**Do NOT move on until:** Process struct is solid

---

#### **Step 4.2: Switch to U-mode**
**Goal:** Jump from S-mode kernel to U-mode user process

**Files to create/modify:**
- `src/kernel.c` - Switch to U-mode logic
- `src/trap.s` - Add code to load process context

**What to implement:**
```c
// In kernel:
struct process *p = create_process(user_app);

// Set up for U-mode:
// - Set sepc to entry point
// - Set sstatus with SPP=0 (U-mode)
// - Load registers from process struct
// - sret to U-mode
```

**What to verify:**
- Kernel successfully switches to U-mode
- User app starts running
- Can see "Hello from U-mode" output

**Success criteria:**
- ✓ See user app output
- ✓ Code runs in U-mode (not S-mode)
- ✓ No crashes when entering U-mode

**Do NOT move on until:** User mode works

---

#### **Step 4.3: Return from U-mode to Kernel**
**Goal:** User code makes syscall (ecall), kernel handles it

**Files to create/modify:**
- `src/user_app.c` - Add ecall instruction
- `src/syscall.c` - Syscall handler
- `src/kernel.c` - Dispatch syscall

**What to implement:**
```c
// In user app:
asm volatile("ecall");

// In kernel trap handler:
if (cause == 8) {  // ECALL from U-mode
    uart_puts("Syscall from user\n");
    write_csr(0x141, read_csr(0x141) + 4);  // Skip ecall
}

// sret back to user
```

**What to verify:**
- User calls ecall
- Kernel receives trap (cause=8)
- Kernel prints message and returns

**Success criteria:**
- ✓ See "Syscall from user" message
- ✓ User code continues after ecall
- ✓ No crashes

**Do NOT move on until:** Syscall trap works

---

### Phase 5: System Calls (Days 9-10)

---

#### **Step 5.1: SYS_WRITE - Print from User**
**Goal:** User app can call print via syscall

**Files to create/modify:**
- `src/syscall.c` - Implement SYS_WRITE handler
- `src/syscall.h` - Syscall definitions
- `src/user_app.c` - Use SYS_WRITE

**What to implement:**
```c
#define SYS_WRITE 64

// In user app:
asm volatile("ecall");  // Syscall

// In kernel:
if (cause == 8) {  // ECALL
    uint32_t syscall_num = read_register(x17);  // a7
    if (syscall_num == SYS_WRITE) {
        char *str = (char *)read_register(x10);  // a0
        uart_puts(str);
    }
}
```

**What to verify:**
- User app passes data to kernel via registers
- Kernel prints that data
- Output appears in QEMU

**Success criteria:**
- ✓ User app calls SYS_WRITE
- ✓ Text appears on screen
- ✓ Kernel interprets registers correctly

**Do NOT move on until:** User can print via syscall

---

#### **Step 5.2: SYS_EXIT - Kill Process**
**Goal:** User app can exit gracefully

**Files to create/modify:**
- `src/syscall.c` - Add SYS_EXIT handler
- `src/user_app.c` - Call SYS_EXIT at end

**What to implement:**
```c
#define SYS_EXIT 93

// In user app:
asm volatile("ecall");  // SYS_EXIT

// In kernel:
if (syscall_num == SYS_EXIT) {
    uart_puts("Process exiting\n");
    current_process->state = DEAD;
    // Switch to next process or halt
}
```

**What to verify:**
- User app exits
- Kernel prints exit message
- System doesn't crash

**Success criteria:**
- ✓ User app exits cleanly
- ✓ Kernel prints exit message
- ✓ Process marked as DEAD

**Do NOT move on until:** Process exit works

---

#### **Step 5.3: SYS_YIELD - Voluntary Context Switch**
**Goal:** User can voluntarily give up CPU time

**Files to create/modify:**
- `src/syscall.c` - Add SYS_YIELD handler
- `src/scheduler.c` - Basic scheduler
- `src/user_app.c` - Call SYS_YIELD

**What to implement:**
```c
#define SYS_YIELD 124

// In kernel:
if (syscall_num == SYS_YIELD) {
    uart_puts("Yield\n");
    // Pick next process
    // Switch to it
    // sret to next process
}
```

**What to verify:**
- User yields
- Kernel acknowledges
- Can handle multiple yields

**Success criteria:**
- ✓ SYS_YIELD handler works
- ✓ See "Yield" messages
- ✓ No crashes

**Do NOT move on until:** Voluntary yield works

---

### Phase 6: Scheduling (Days 11-12)

---

#### **Step 6.1: Create Multiple Processes**
**Goal:** Kernel can create and track 2+ user processes

**Files to create/modify:**
- `src/scheduler.c` - Process queue management
- `src/kernel.c` - Create 2 processes
- `src/user_app.c` - Two different apps (app1, app2)

**What to implement:**
```c
struct process {
    uint32_t pid;
    uint32_t state;  // READY, RUNNING, DEAD
    uint32_t *stack;
    uint32_t sepc;
    uint32_t sstatus;
    // ...
};

void create_process(void (*entry)());
struct process* next_process();
```

**What to verify:**
- Two processes created successfully
- Can iterate through process list
- No crashes

**Success criteria:**
- ✓ Both processes in memory
- ✓ Can enumerate processes
- ✓ Scheduler picks first one

**Do NOT move on until:** Multiple processes created

---

#### **Step 6.2: Round-Robin Scheduling**
**Goal:** Switch between processes fairly

**Files to create/modify:**
- `src/scheduler.c` - Round-robin logic
- `src/user_app1.c` - First app
- `src/user_app2.c` - Second app

**What to implement:**
```c
struct process *current;
struct process *processes[4];

struct process* schedule() {
    current_index = (current_index + 1) % num_processes;
    if (processes[current_index]->state == DEAD)
        return schedule();  // Skip dead processes
    return processes[current_index];
}
```

**What to verify:**
- Can switch between processes
- Both execute some code
- Fair scheduling (not stuck on one)

**Success criteria:**
- ✓ See output from both processes
- ✓ Can manually trigger switch via SYS_YIELD
- ✓ Processes take turns

**Do NOT move on until:** Two processes alternate execution

---

#### **Step 6.3: Timer Interrupt for Context Switching**
**Goal:** CPU automatically switches processes on timer

**Files to create/modify:**
- `src/boot.s` - Enable timer interrupt in M-mode
- `src/kernel.c` - Set up timer in S-mode
- `src/trap.c` - Handle timer interrupt

**What to implement:**
```c
// In boot.s:
// mie[7] = MTIE (Machine Timer Interrupt Enable)

// In kernel:
// sstatus[5] = STIE (Supervisor Timer Interrupt Enable)
// Set mtimecmp register to fire periodic interrupts

// In trap handler:
if (cause == (1 << 31 | 5)) {  // Timer interrupt
    schedule();  // Switch to next process
}
```

**What to verify:**
- Timer interrupts at regular intervals
- Process switches on interrupt
- See interleaved output from both processes

**Success criteria:**
- ✓ Timer fires periodically
- ✓ Kernel receives interrupt
- ✓ Processes switch automatically
- ✓ See interleaved output: "App1... App2... App1... App2..."

**Do NOT move on until:** Processes switch automatically on timer

---

### Phase 7: Memory Management (Days 13-14) - OPTIONAL

---

#### **Step 7.1: Simple Allocator**
**Goal:** Kernel can allocate memory for processes

**Files to create/modify:**
- `src/alloc.c` - Simple bump allocator
- `src/kernel.c` - Use allocator for process stacks

**What to implement:**
```c
void* kmalloc(size_t size);
void kfree(void *ptr);  // Optional (bump allocator just bumps)
```

**Success criteria:**
- ✓ Can allocate memory
- ✓ Each process gets own stack
- ✓ No overlaps

---

#### **Step 7.2: Basic Memory Map**
**Goal:** Understand and document memory layout

**Files to create/modify:**
- `docs/MEMORY.md` - Memory layout documentation

**What to document:**
```
0x80200000 - Kernel code starts
0x80200000 + kernel_size - Kernel data ends
0x80200000 + 1MB - Kernel heap starts
0x80200000 + 4MB - Process 1 stack
0x80200000 + 8MB - Process 2 stack
...
```

**Success criteria:**
- ✓ Memory layout documented
- ✓ All sections fit without overlap
- ✓ Each process has stack space

---

### Phase 8: Polish & Documentation (Days 15)

---

#### **Step 8.1: Comprehensive Documentation**
**Files to create:**
- `README.md` - Project overview
- `docs/ARCHITECTURE.md` - Design
- `docs/BUILD.md` - How to build
- `docs/DEBUGGING.md` - GDB tips
- `docs/SYSCALLS.md` - Available syscalls

**What to document:**
- System architecture
- Boot sequence
- Trap handling
- Process management
- Syscall interface

---

#### **Step 8.2: Code Cleanup**
- Remove debug prints (or make toggleable)
- Add comments to complex sections
- Organize code logically
- Consistent naming

---

#### **Step 8.3: Final Testing**
- Test all syscalls
- Test edge cases
- Test with multiple processes
- Verify no memory corruption

---

## Testing Checklist

For each step, verify:

- [ ] Code compiles: `make all` succeeds
- [ ] Disassembly looks correct: `make disasm | head -30`
- [ ] Runs in QEMU: `make run` boots without crash
- [ ] GDB debugging works: Can set breakpoint, step, inspect registers
- [ ] Expected output appears
- [ ] No memory corruption
- [ ] Behavior matches step goals

---

## Key Commands

```bash
# Build
make clean && make all

# View machine code
make disasm | head -30

# Run in QEMU
make run  # Exit: Ctrl+A then X

# Debug with GDB
make debug

# Useful GDB commands:
break _start
continue
step / si
info registers
x/10i $pc
quit
```

---

## Time Estimates

- **Phase 1:** 2 days (foundation)
- **Phase 2:** 2 days (privilege modes)
- **Phase 3:** 2 days (exceptions)
- **Phase 4:** 2 days (user mode)
- **Phase 5:** 2 days (syscalls)
- **Phase 6:** 2 days (scheduling)
- **Phase 7:** 2 days (memory) - optional
- **Phase 8:** 1 day (polish)

**Total:** 15 days for complete minimal OS

You can skip Phase 7 (memory) and still have a working OS.

---

## Success Criteria - Final Project

When done, your OS should:

- ✓ Boot from OpenSBI to kernel
- ✓ Print messages from kernel (S-mode)
- ✓ Handle exceptions (traps)
- ✓ Create multiple user processes (U-mode)
- ✓ Switch between processes (scheduler)
- ✓ Handle syscalls (user → kernel → user)
- ✓ Run user code with timer preemption
- ✓ Exit processes gracefully

**That's a complete minimal OS!**

---

## Next Action

Start with **Step 1.1: Project Setup & Build System**

Once you complete it (all checkboxes pass), move to **Step 1.2: UART Output**

Tell me when each step is complete, and I'll help debug or move you to the next one.

