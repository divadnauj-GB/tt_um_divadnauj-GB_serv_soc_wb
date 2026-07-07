# Include the core environment definitions; this will set $(TOP).
include ../micropython/py/mkenv.mk

QEMU ?=

SPIKE ?=

CROSS = 1

PATCH ?=

QSTR_DEFS = qstrdefsport.h

MICROPY_ROM_TEXT_COMPRESSION ?= 0


ifdef QEMU
	CFLAGS+=-O2 -DQEMU 
	BOARD ?=qemu
	SIM=qemu-system-riscv32 -machine virt -nographic --no-reboot -bios
	PATCH_SH=
	DEFINT16=
	
else ifdef  SPIKE
	CFLAGS+=-O2 -DSPIKE 
	BOARD ?=serv_spike
	SIM=~/spike/bin/spike --isa=rv32e_zicsr -m0x00010000:0x4000000 --dtb=utils/serv2.dtb 
	ifdef PATCH
		PATCH_SH=python ../0-riscv-nmon/elf_sh_patcher.py build/firmware.elf -c riscv64-unknown-elf-
		DEFINT16=-D__UINT16_TYPE__=__UINT32_TYPE__ -D__INT16_TYPE__=__INT32_TYPE__ -Duint16_t=uint32_t -Dint16_t=int32_t 
	else
		PATCH_SH=
		DEFINT16=
	endif
else
	CFLAGS+=-O2
	#BOARD ?=SERVE-wb-soc
	BOARD ?=serv
	ifdef PATCH
		PATCH_SH=python ../0-riscv-nmon/elf_sh_patcher.py build/firmware.elf -c riscv64-unknown-elf-
		DEFINT16=-D__UINT16_TYPE__=__UINT32_TYPE__ -D__INT16_TYPE__=__INT32_TYPE__ -Duint16_t=uint32_t -Dint16_t=int32_t 
	else
		PATCH_SH=
		DEFINT16=
	endif
endif

# Include py core make definitions.
include $(TOP)/py/py.mk
include $(TOP)/extmod/extmod.mk


CROSS_COMPILE ?= riscv64-unknown-elf-
GCC_VERSION = $(word 1, $(subst ., , $(shell $(CC) -dumpversion)))
INC += -I. -I$(BUILD) -I$(TOP) -I./inc -I./uPython

ARCH=-march=rv32e_zicsr -mabi=ilp32e

AFLAGS +=$(ARCH) $(INC) 
CFLAGS_RV32E = $(ARCH) -ffreestanding -Wdouble-promotion -Wfloat-conversion -specs=nano.specs --specs=nosys.specs
CFLAGS+= $(INC) -Wall -std=c11 -nostdlib $(CFLAGS_RV32E) $(COPT) $(DEFINT16)


LDFLAGS +=$(ARCH) $(INC) -nostdlib -ffreestanding -specs=nano.specs --specs=nosys.specs -Wl,--no-relax,--strip-debug,-Map=$@.map,-Bstatic,-T,$(BOARD).lds,--gc-sections

#CFLAGS += -fdata-sections -ffunction-sections

CXXFLAGS += $(filter-out -std=c99,$(CFLAGS))

LIBS += -lc -lgcc 

# Define the required source files.
SRC_C = \
    main.c \
    mphalport.c \
	uPython/nlrrv32.c \
    shared/readline/readline.c \
    shared/runtime/gchelper_native.c \
    shared/runtime/pyexec.c \
    shared/runtime/stdout_helpers.c \
    shared/libc/printf.c \
	shared/timeutils/timeutils.c \
	shared/libc/string0.c \
	$(BUILD)/_frozen_mpy.c \
    



SRC_C += $(wildcard src/*.c)
ASM_SRC = $(wildcard *.S)
# Define source files containung qstrs.
SRC_QSTR += shared/readline/readline.c shared/runtime/pyexec.c 

PY_O := $(filter-out $(BUILD)/py/nlrrv32.o, $(PY_O))
# Define the required object files.
OBJ += $(PY_O) 
OBJ += $(addprefix $(BUILD)/, $(SRC_C:.c=.o))
OBJ += $(addprefix $(BUILD)/, $(SRC_CXX:.cpp=.o))
OBJ += $(addprefix $(BUILD)/, $(ASM_SRC:.S=.o))
OBJ += $(BUILD)/uPython/gchelper_rv32e.o

# Define the top-level target, the main firmware.
all: $(BUILD)/firmware.elf
nmon: $(BUILD)/firmware.nmon


$(BUILD)/_frozen_mpy.c: $(TOP)/tests/frozen/frozentest.mpy $(BUILD)/genhdr/qstrdefs.generated.h
	$(ECHO) "MISC freezing bytecode"
	$(Q)$(TOP)/tools/mpy-tool.py -f -q $(BUILD)/genhdr/qstrdefs.preprocessed.h -mlongint-impl=none $< > $@

    
# Define how to build the firmware.
$(BUILD)/firmware.elf: $(OBJ)
	$(ECHO) "LINK $@"
	$(Q)$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)
	$(Q)$(SIZE) -A -x $@
	$(PATCH_SH)

run: $(BUILD)/firmware.elf
	 $(SIM) $(BUILD)/firmware.elf 

	
$(BUILD)/firmware.bin: $(BUILD)/firmware.elf
	$(CROSS_COMPILE)objcopy -O binary $< $@
	$(CROSS_COMPILE)objdump -s -d $(BUILD)/firmware.elf >> $(BUILD)/mp.S
	$(CROSS_COMPILE)readelf -s $(BUILD)/firmware.elf >> $(BUILD)/relf.log
	$(CROSS_COMPILE)nm -s $(BUILD)/firmware.elf >> $(BUILD)/nm.log


pre-flash: $(BUILD)/firmware.bin
	cp $(BUILD)/firmware.bin $(BUILD)/firmware-pre-flash.bin
	dd if=../0-riscv-nmon/serv-e-wb-soc_25MHz_115200.bin of=$(BUILD)/firmware-pre-flash.bin bs=1 seek=0 conv=notrunc
	echo "@000000" > firmware-f.hex
	hexdump -v -e '"" 32/1 "%02x " "\n"' $(BUILD)/firmware-pre-flash.bin >> firmware-f.hex
	truncate -s 16M $(BUILD)/firmware-pre-flash.bin

$(BUILD)/firmware.nmon: $(BUILD)/firmware.bin
	@START_ADDR=$$($(CROSS_COMPILE)nm $(BUILD)/firmware.elf | awk '/ _start/ {print $$1}'); \
	echo "Start address: 0x$$START_ADDR"; \
	xxd -e -c 4 -o 0x$$START_ADDR -g 4 $< | awk '{gsub(":", "", $$1); print "send \"w"$$1$$2"\""}'  > .tmp ; \
	awk '{print "expect \"nmon> \"\n" $$0}' .tmp > $@ ; \
	echo "expect \"nmon> \"" >> $@ ; \
	echo "send \"g$$START_ADDR\"" >> $@ ; \
	xxd -e -c 4 -o 0x$$START_ADDR -g 4 $< | awk '{gsub(":", "", $$1); print ""$$1$$2""}'  > .tmp ; 
	xxd -e -c 4 -o 0x$$START_ADDR -g 4 $< | awk '{gsub(":", "", $$1); print ""$$2""}'  > .tmp2 ; 
	echo "@000000" > firmware-f.hex
	hexdump -v -e '"" 32/1 "%02x " "\n"' $< >> firmware-f.hex


# Include remaining core make rules.
include $(TOP)/py/mkrules.mk