# Makefile - RISC-V OS 
#
# Toolchain (Arch Linux uses riscv64-elf*)
TOOLCHAIN = riscv64-elf
CC = $(TOOLCHAIN)-gcc
AS = $(TOOLCHAIN)-as
LD = $(TOOLCHAIN)-ld
LDSCRIPT_SRC = linker.ld.S
LDSCRIPT = linker.ld
OBJCOPY = $(TOOLCHAIN)-objcopy
OBJDUMP = $(TOOLCHAIN)-objdump
CORE_DIR = core

# Compiler flags
CFLAGS = -march=rv32i_zicsr -mabi=ilp32 -nostdlib -fno-builtin -ffreestanding -O0 -g -I$(CORE_DIR)
ASFLAGS = -march=rv32i_zicsr -mabi=ilp32
LDFLAGS = -m elf32lriscv -T $(LDSCRIPT)

LOG_LEVEL ?= 3
CFLAGS += -DLOG_LEVEL=$(LOG_LEVEL)


# Kernel-side objects: participate in the link as-is
CORE_OBJECTS = \
	boot.o \
	$(CORE_DIR)/trap.o \
	$(CORE_DIR)/trap_handler.o \
	$(CORE_DIR)/kernel.o \
	$(CORE_DIR)/uart.o \
	$(CORE_DIR)/proc.o \
	$(CORE_DIR)/panic.o

# User-mode objects: compiled normally, then have their sections
# renamed before linking so the linker script can match them with
# a bare *(.utext)/*(.udata)/*(.urodata) wildcard, no path globs.
USER_OBJECTS = \
	bin/common/crt0.o \
	bin//common/syscall.o \
	bin/shell/shell.o \
	bin/yield_test/yield_test.o

USER_OBJECTS_RENAMED = $(USER_OBJECTS:.o=.user.o)
OBJECTS = $(CORE_OBJECTS) $(USER_OBJECTS_RENAMED)



# Output
KERNEL = kernel.elf

# Targets 
.PHONY: all clean run debug disasm

all: $(KERNEL)

# Rules
$(LDSCRIPT): $(LDSCRIPT_SRC) $(CORE_DIR)/mem_layout.h
	$(CC) -E -x assembler-with-cpp -undef -P -I$(CORE_DIR) $< -o $@

$(KERNEL): $(OBJECTS) $(LDSCRIPT)
	$(LD) $(LDFLAGS) $(OBJECTS) -o $@

# Intermediate step: rename sections in the already-compiled object,
# runs after the normal .o is built, before it reaches the linker.
%.user.o: %.o
	$(OBJCOPY) \
		--rename-section .text=.utext,alloc,load,readonly,contents,code \
		--rename-section .data=.udata,alloc,load,contents \
		--rename-section .rodata=.urodata,alloc,load,readonly,contents \
		$< $@
	@echo "✓ Renamed sections: $< -> $@"

%.o: %.s
	$(AS) $(ASFLAGS) $< -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

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
	rm -f $(CORE_OBJECTS) $(USER_OBJECTS) $(USER_OBJECTS_RENAMED) $(KERNEL) $(LDSCRIPT)
