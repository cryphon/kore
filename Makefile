# Makefile - RISC-V OS 
#
# Toolchain (Arch Linux uses riscv64-elf*)
TOOLCHAIN = riscv64-elf
CC = $(TOOLCHAIN)-gcc
AS = $(TOOLCHAIN)-as
LD = $(TOOLCHAIN)-ld
OBJDUMP = $(TOOLCHAIN)-objdump
CORE_DIR = ./core

# Compiler flags
CFLAGS = -march=rv32i_zicsr -mabi=ilp32 -nostdlib -fno-builtin -ffreestanding -O0 -g -I$(CORE_DIR)
ASFLAGS = -march=rv32i_zicsr -mabi=ilp32
LDFLAGS = -m elf32lriscv -T linker.ld

# Logging level
CFLAGS += -DLOG_LEVEL=2


OBJECTS = \
		boot.o \
		crt0.o \
		$(CORE_DIR)/trap.o \
		$(CORE_DIR)/trap_handler.o \
		$(CORE_DIR)/kernel.o \
		$(CORE_DIR)/uart.o \
		$(CORE_DIR)/proc.o \
		$(CORE_DIR)/panic.o \
		$(CORE_DIR)/syscall.o \
		bin/shell.o \

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
	$(OBJDUMP) -d $(KERNEL)
run: $(KERNEL)
	qemu-system-riscv32 -M virt -bios none -kernel $(KERNEL) -nographic
debug: $(KERNEL)
	qemu-system-riscv32 -M virt -bios none -kernel $(KERNEL) \
		-gdb tcp::1234 -S -nographic &
	riscv64-elf-gdb $(KERNEL) -ex "target remote :1234"
new:
	@if [ -z "$(TYPE)" ] || [ -z "$(NAME)" ]; then \
		echo "Usage: make new TYPE=<c|h|s|ld> NAME=<filename> [LOC=<directory>]"; \
		exit 1; \
	fi
	@./tools/newfile.sh $(TYPE) $(NAME) $(LOC)
clean:
	rm -f $(OBJECTS) $(KERNEL)
