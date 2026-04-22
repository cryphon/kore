# Makefile - RISC-V OS 
#
# Toolchain (Arch Linux uses riscv64-elf*)
TOOLCHAIN = riscv64-elf
CC = $(TOOLCHAIN)-gcc
AS = $(TOOLCHAIN)-as
LD = $(TOOLCHAIN)-ld
OBJDUMP = $(TOOLCHAIN)-objdump

# Compiler flags
CFLAGS = -march=rv32i -mabi=ilp32 -nostdlib -fno-builtin -ffreestanding -O0 -g
ASFLAGS = -march=rv32i_zicsr -mabi=ilp32
LDFLAGS = -m elf32lriscv -T linker.ld

OBJECTS = \
		boot.o \
		kernel/kernel.o \
		kernel/uart.o \

# Output
KERNEL = kernel.elf

# Targets 
.PHONY: all clean run debug disasm

all: $(KERNEL)

# Rules
$(KERNEL): $(OBJECTS)
	$(LD) $(LDFLAGS) $^ -o $@
	@echo "✓ Linked: $@"

%.o: %.s
	$(AS) $(ASFLAGS) $< -o $@
	@echo "✓ Assembled: $<"

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@
	@echo "✓ Compiled: $<"

disasm: $(KERNEL)
	$(OBJDUMP) -d $(KERNEL) | head -50
run: $(KERNEL)
	qemu-system-riscv32 -M virt -bios none -kernel $(KERNEL) -nographic
debug: $(KERNEL)
	qemu-system-riscv32 -M virt -bios none -kernel $(KERNEL) \
		-gdb tcp::1234 -S -nographic &
	riscv64-elf-gdb $(KERNEL) -ex "target remote :1234"
clean:
	rm -f $(OBJECTS) $(KERNEL)
