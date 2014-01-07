.PHONY: all clean flash ftdi openocd reset

TOOLPREFIX = arm-unknown-linux-gnu-
UTILPREFIX = ../util/
BIN = bin
SRC = src

CC = $(TOOLPREFIX)gcc
LD = $(TOOLPREFIX)ld
OBJDUMP = $(TOOLPREFIX)objdump
OBJCOPY = $(TOOLPREFIX)objcopy

MKUDFU = $(UTILPREFIX)mkudfu
DFU_UTIL = $(UTILPREFIX)dfu-util

CFLAGS = -mcpu=arm920t -mtune=arm920t -ggdb -Iinclude -nostdinc -fno-builtin -O2
LDFLAGS =

BOOT_OBJS = $(addprefix $(BIN)/, boot.o clock.o memory.o printf.o uart.o flash.o string.o led.o)
KERNEL_OBJS = $(addprefix $(BIN)/, kernel.o glamo.o uart.o printf.o lcm.o i2c.o power.o)

$(BIN)/%.o: $(SRC)/%.c
	$(CC) $(CFLAGS) -c -o $@ $^
$(BIN)/%.o: $(SRC)/%.S
	$(CC) $(CFLAGS) -c -o $@ $^

all: $(BIN)/boot.bin $(BIN)/kernel.bin $(BIN)/bootblock.S

$(BIN)/bootblock.o: $(BIN)/bootasm.o $(BOOT_OBJS)
	$(LD) $(LDFLAGS) -N -e start -Ttext 0x0 -o $@ $^

$(BIN)/boot.raw: $(BIN)/bootblock.o
	$(OBJCOPY) -S -O binary $^ $@

$(BIN)/boot.bin: $(BIN)/boot.raw
	$(MKUDFU) -v 0x1d50 -p 0x5119 -r 0x0350 -d $^ $@

$(BIN)/bootblock.S: $(BIN)/bootblock.o
	$(OBJDUMP) -S $^ > $@

$(BIN)/kernelblock.o: $(BIN)/kernelasm.o $(KERNEL_OBJS)
	$(LD) $(LDFLAGS) -N -e start -Ttext 0x30000000 -o $@ $^

$(BIN)/kernel.raw: $(BIN)/kernelblock.o
	$(OBJCOPY) -S -O binary $^ $@

$(BIN)/kernel.bin: $(BIN)/kernel.raw
	$(MKUDFU) -v 0x1d50 -p 0x5119 -r 0x0350 -d $^ $@

flashboot: $(BIN)/boot.bin
	$(DFU_UTIL) -a u-boot -R -D $^

flashfs:
	$(MKUDFU) -v 0x1d50 -p 0x5119 -r 0x0350 -d $(BIN)/NK.bin $(BIN)/fs.bin
	$(DFU_UTIL) -a rootfs -R -D $(BIN)/fs.bin

flashkernel: $(BIN)/kernel.bin
	$(DFU_UTIL) -a kernel -R -D $^

ftdi:
	rmmod ftdi_sio
	modprobe ftdi_sio vendor=0x1457 product=0x5118

openocd:
	openocd -f $(UTILPREFIX)openocd.cfg &

clean:
	rm -f $(BIN)/*
