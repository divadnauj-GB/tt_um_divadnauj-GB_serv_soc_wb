PROJECT = serv-e-wb-soc_25MHz_115200
FLASH_SIZE = 16777216
CROSS_COMPILE=riscv32-unknown-elf-

CC=$(CROSS_COMPILE)gcc
OBJCOPY=$(CROSS_COMPILE)objcopy
NM=$(CROSS_COMPILE)nm
SIZE=$(CROSS_COMPILE)size

ARCH=-march=rv32e_zicsr -mabi=ilp32e
LINKERSCRIPT=riscv_nmon.lds
CFLAGS+=$(ARCH) -Wall -Wextra  -std=c11 -ffreestanding

CFLAGS+=-g 
CFLAGS+=-fno-pic --specs=nano.specs --specs=nosys.specs
CFLAGS+=$(ARCH)

LDFLAGS +=-T$(LINKERSCRIPT) 
LDFLAGS +=-nostdlib 
LDFLAGS +=-Wl,--no-relax 

LDLIBS = -lc -lgcc

C_SRC = $(wildcard *.c)
ASM_SRC = $(wildcard *.S)
# Convert the list of .c files into a list of .o object files
OBJS = $(patsubst %.c, %.o, $(C_SRC))
OBJS += $(patsubst %.S, %.o, $(ASM_SRC))

build: $(PROJECT).elf $(PROJECT).txt



%.o: %.S
	$(CC) $(CFLAGS) -c $^ -o $@ 
	
%.o: %.c 
	$(CC) $(CFLAGS)  -c $< -o $@ 

%.bin: %.elf
	$(OBJCOPY) -O binary $< $@

$(PROJECT).elf: $(PROJECT).o
	$(CC) $(CFLAGS) $(LDFLAGS) $(PROJECT).o $(LDLIBS) -o $@ 
	$(SIZE) -A -x $@

START_ADDR:=80000000
%.txt: %.bin
	hexdump -v -e '/4 "%08x\n"' $< > $@
	@xxd -e -c 4 -o 0x$(START_ADDR) -g 4 $< | awk '{gsub(":", "", $$1); print ""$$1$$2""}'  > .tmp ;
	echo "@000000" > firmware.hex
	hexdump -v -e '"" 32/1 "%02x " "\n"' $< >> firmware.hex
	truncate -s 16M $(PROJECT).bin
	mv $(PROJECT).bin flash.bin

	# dd if=/dev/zero of=flash.bin bs=1 count=$(FLASH_SIZE)
	# dd if=$(PROJECT).bin of=flash.bin conv=notrunc
	# Optional: Append extra data to a specific offset
	# echo "ExtraData" | dd of=flash.bin bs=1 seek=10000000 conv=notrunc



clean:
	rm -f *.o *.elf *.img *.nmon symbols.txt .tmp *.txt *.hex *.bin
