# Options:
# 	- all:		compile object files and main.c, create executable
# 	- lib:		generate bootstrap object file only
# 	- clean: 	remove all object files from build directory
# 	- purge:	clean and remove executables from build directory

CC ?= gcc
AS ?= as
LD ?= ld

COMPAT32 ?= 0	# set to 1 if building 32-bit on a 64-bit system
DEBUG ?= 0		# set to 1 for debugging symbols

BUILD ?= ./build
SRC ?= ./src
LIB ?= ./lib
INCLUDE ?= ./include

# ARCH can be one of the following (see lib/*.s):
# 	- x86_64
# 	- x86_32
# 	- armhf

ARCH ?= x86_64

ifeq ($(ARCH),x86_32)
ifeq ($(COMPAT32),1)
	CFLAGS += -m32
	ASFLAGS += --32
	LDFLAGS += -melf_i386
endif
endif

ifeq ($(DEBUG),1)
	CFLAGS += -g
	ASFLAGS += -g
endif

.PHONY: all lib clean purge

all: $(BUILD)/main.o $(BUILD)/bootstrap.o
	$(LD) $(LDFLAGS) -nostdlib -o $(BUILD)/main.elf $^

lib: $(BUILD)/bootstrap.o

clean:
	rm -f $(BUILD)/*.o

purge: clean
	rm -f $(BUILD)/*.elf

$(BUILD):
	mkdir -p $@

$(BUILD)/bootstrap.o: $(LIB)/$(ARCH).s $(BUILD) 
	$(AS) $(ASFLAGS) -o $@ $<

$(BUILD)/%.o: $(SRC)/%.c $(BUILD) 
	$(CC) $(CFLAGS) -I$(INCLUDE) -c -o $@ $<

