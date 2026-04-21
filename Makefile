# Makefile - RISC-V OS 
#
# Toolchain (Arch Linux uses riscv64-elf*)
TOOLCHAIN = riscv64-elf
CC = $(TOOLCHAIN)-cc
AS = $(TOOLCHAIN)-as
LD = $(TOOLCHAIN)-ld
OBJDUMP = $(TOOLCHAIN)-objdump

# Compiler flags
CFLAGS = -march=rv32i -mabi=ilp32 -nostdlib -fno-builtin -O0 -g
ASFLAGS = -march=rv32i -mabi=ilp32
LDFLAGS = -m elf32lriscv -T linker.ld

# Source files
SOURCES = boot.s
OBJECTS = boot.o

# Output
KERNEL = kernel.elf

# Targets 
.PHONY: all clean run debug disasm

all: $(KERNEL)

$(KERNEL): $(OBJECTS)
	$(LD) $(LDFLAGS) $^ -o $@
	@echo "✓ Linked: $@"

%.o: %.s
	$(AS) $(ASFLAGS) $< -o $@
	@echo "✓ Assembled: $<"

disasm: $(KERNEL)
	$(OBJDUMP) -d $(KERNEL) | head -50

run: $(KERNEL)
	qemu-system-riscv32 -M virt -kernel $(KERNEL) -nographic

debug: $(KERNEL)
	qemu-system-riscv32 -M virt -kernel $(KERNEL) \
		-gdb tcp::1234 -S -nographic &
	riscv64-elf-gdb $(KERNEL) -ex "target remote :1234"

clean:
	rm -f $(OBJECTS) $(KERNEL)
