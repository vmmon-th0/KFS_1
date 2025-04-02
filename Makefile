TARGET = i686-elf

OBJ_DIR = obj
SRC_DIR = src
KERNEL_DIR = kernel

BOOT_SRC = $(SRC_DIR)/boot.s
KERNEL_SRC = $(SRC_DIR)/kernel.c
LINKER_SCRIPT = $(SRC_DIR)/linker.ld
GRUB_CFG = grub.cfg

MYOS_ISO = myos.iso
MYOS_BIN = myos.bin

KERNEL_BIN = $(KERNEL_DIR)/$(MYOS_BIN)
KERNEL_ISO = $(KERNEL_DIR)/$(MYOS_ISO)

CC = $(HOME)/opt/cross/bin/$(TARGET)-gcc
AS = $(HOME)/opt/cross/bin/$(TARGET)-as
LD = $(HOME)/opt/cross/bin/$(TARGET)-ld

ASFLAGS = -I$(SRC_DIR)
CFLAGS  = -std=gnu99 -ffreestanding -O2 -Wall -Wextra -I$(SRC_DIR)
LDFLAGS = -T $(LINKER_SCRIPT) -ffreestanding -O2 -nostdlib

OBJS = $(OBJ_DIR)/boot.o $(OBJ_DIR)/kernel.o

all: $(KERNEL_BIN) $(KERNEL_ISO)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.s | $(OBJ_DIR)
	$(AS) $(ASFLAGS) $< -o $@

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c | $(OBJ_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(KERNEL_BIN): $(OBJS) $(LINKER_SCRIPT)
	$(CC) $(LDFLAGS) -o $@ $(OBJS) -lgcc

$(KERNEL_ISO): $(KERNEL_BIN) $(GRUB_CFG) | $(KERNEL_DIR)
	mkdir -p $(KERNEL_DIR)/boot/grub
	cp $(KERNEL_BIN) $(KERNEL_DIR)/boot/
	cp $(GRUB_CFG) $(KERNEL_DIR)/boot/grub/
	grub-mkrescue --compress=xz -o $@ $(KERNEL_DIR)

$(OBJ_DIR) $(KERNEL_DIR):
	mkdir -p $@

run-bin: $(KERNEL_BIN)
	qemu-system-i386 $(QEMU_FLAGS) -kernel $<

run-iso: $(KERNEL_ISO)
	qemu-system-i386 $(QEMU_FLAGS) -cdrom $<

clean:
	rm -rf $(OBJ_DIR) $(KERNEL_DIR) $(MYOS_ISO)

.PHONY: all clean run run-iso run-bin