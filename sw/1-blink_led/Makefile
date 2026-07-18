CROSS_COMPILE=riscv32-unknown-elf-

ifdef PATCH
	PATCH_SH=python ../0-riscv-nmon/elf_sh_patcher.py application.elf -c $(CROSS_COMPILE)
	DEFINT16=-D__UINT16_TYPE__=__UINT32_TYPE__ -D__INT16_TYPE__=__INT32_TYPE__ -Duint16_t=uint32_t -Dint16_t=int32_t 
endif

CC=$(CROSS_COMPILE)gcc
OBJCOPY=$(CROSS_COMPILE)objcopy
NM=$(CROSS_COMPILE)nm
ARCH=-march=rv32e_zicsr -mabi=ilp32e
LINKERSCRIPT?=SERVE-wb-soc.lds
CFLAGS+=$(ARCH) -Wall -Wextra  -std=c11 -ffreestanding

CFLAGS+=-O3
CFLAGS+=-fno-pic --specs=nano.specs --specs=nosys.specs
CFLAGS+=$(ARCH)

LDFLAGS +=-T$(LINKERSCRIPT) 
LDFLAGS +=-nostdlib 
LDFLAGS +=-Wl,--no-relax,-Map=$@.map

LDLIBS = -lc -lgcc

C_SRC = $(wildcard *.c)
ASM_SRC = $(wildcard *.S)
# Convert the list of .c files into a list of .o object files
OBJS = $(patsubst %.c, %.o, $(C_SRC))
OBJS += $(patsubst %.S, %.o, $(ASM_SRC))

build: application.elf 
nmon: application.nmon


%.o: %.S
	$(CC) $(CFLAGS) -c $^ -o $@ 
	
%.o: %.c 
	$(CC) $(CFLAGS)  -c $< -o $@ 

%.bin: %.elf
	$(OBJCOPY) -O binary $< $@

application.elf: $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) $(OBJS) $(LDLIBS) -o $@ 
	$(CROSS_COMPILE)size -A -x $@
	$(PATCH_SH)

#START_ADDR := $(shell $(NM) *.elf | awk '/ _start/ {print $$1}')

#xxd -e -c 4 -o 0x$(START_ADDR) -g 4 $< | sed "s/^/w/;s/: //;s/  .*//" > $@
application.nmon: application.bin
	@START_ADDR=$$($(NM) *.elf | awk '/ _start/ {print $$1}'); \
	echo "Start address: 0x$$START_ADDR"; \
	xxd -e -c 4 -o 0x$$START_ADDR -g 4 $< | awk '{gsub(":", "", $$1); print "send \"w"$$1$$2"\"\nsend \"d"$$1"\""}'  > .tmp ; \
	awk '{print "expect \"nmon> \"\n" $$0}' .tmp > $@ ; \
	echo "expect \"nmon> \"" >> $@ ; \
	echo "send \"g$$START_ADDR\"" >> $@ ; \
	xxd -e -c 4 -o 0x$$START_ADDR -g 4 $< | awk '{gsub(":", "", $$1); print ""$$1$$2""}'  > .tmp ; 
	xxd -e -c 4 -o 0x$$START_ADDR -g 4 $< | awk '{gsub(":", "", $$1); print ""$$2""}'  > .tmp2 ; 

	echo "@000000" > firmware.hex
	hexdump -v -e '"" 32/1 "%02x " "\n"' $< >> firmware.hex



clean:
	rm -f *.o *.elf *.img *.bin *.nmon symbols.txt .tmp* *.txt *.hex *.log  *.map
