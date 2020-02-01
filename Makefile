# Makefile to rebuild SM64 split image

### Default target ###

default: all

### Build Options ###

# These options can either be changed by modifying the makefile, or
# by building with 'make SETTING=value'. 'make clean' may be required.

# Version of the game to build
VERSION ?= 2.0I
# If COMPARE is 1, check the output sha1sum when building 'all'
COMPARE ?= 1
# If NON_MATCHING is 1, define the NON_MATCHING and AVOID_UB macros when building (recommended)
NON_MATCHING ?= 0
# Build for the N64 (turn this off for ports)
TARGET_N64 ?= 1

# Release


################ Target Executable and Sources ###############

# BUILD_DIR is location where all build artifacts are placed
BUILD_DIR_BASE := build
BUILD_DIR := $(BUILD_DIR_BASE)/$(VERSION)

#LIBULTRA := $(BUILD_DIR)/libultra.a
#ROM := $(BUILD_DIR)/$(TARGET).z64
#ELF := $(BUILD_DIR)/$(TARGET).elf


# Directories containing source files
SRC_DIRS := src src/audio src/gt src/gu src/io src/libc src/os src/rg src/sched src/sp
#ASM_DIRS := asm lib
#BIN_DIRS := bin bin/$(VERSION)

#ULTRA_SRC_DIRS := lib/src lib/src/math
#ULTRA_ASM_DIRS := lib/asm lib/data
#ULTRA_BIN_DIRS := lib/bin

#GODDARD_SRC_DIRS := src/goddard src/goddard/dynlists


MIPSISET := -mips2 -32

OPT_FLAGS := -O1

C_FILES := $(foreach dir,$(SRC_DIRS),$(wildcard $(dir)/*.c))
S_FILES := $(foreach dir,$(SRC_DIRS),$(wildcard $(dir)/*.s))

# Object files
O_FILES := $(foreach file,$(C_FILES),$(BUILD_DIR)/$(file:.c=.o)) \
           $(foreach file,$(S_FILES),$(BUILD_DIR)/$(file:.s=.o)) 

# Automatic dependency files
DEP_FILES := $(O_FILES:.o=.d)

ALL_DIRS := $(BUILD_DIR) $(addprefix $(BUILD_DIR)/,$(SRC_DIRS)) 

# Make sure build directory exists before compiling anything
DUMMY != mkdir -p $(ALL_DIRS)

##################### Compiler Options #######################
IRIX_ROOT := tools/ido

ifeq ($(shell type mips-linux-gnu-ld >/dev/null 2>/dev/null; echo $$?), 0)
  CROSS := mips-linux-gnu-
else
  CROSS := mips64-elf-
endif

# check that either QEMU_IRIX is set or qemu-irix package installed
ifndef QEMU_IRIX
  QEMU_IRIX := $(shell which qemu-irix)
  ifeq (, $(QEMU_IRIX))
    $(error Please install qemu-irix package or set QEMU_IRIX env var to the full qemu-irix binary path)
  endif
endif

AS        := $(QEMU_IRIX) -silent -L $(IRIX_ROOT) $(IRIX_ROOT)/usr/bin/as
#AS		  := $(CROSS)as
CC        := $(QEMU_IRIX) -silent -L $(IRIX_ROOT) $(IRIX_ROOT)/usr/bin/cc
#AR        := $(QEMU_IRIX) -silent -L $(IRIX_ROOT) $(IRIX_ROOT)/usr/bin/ar
CPP       := cpp -P
LD        := $(CROSS)ld
AR        := $(CROSS)ar
OBJDUMP   := $(CROSS)objdump
OBJCOPY   := $(CROSS)objcopy

ASM_OPT_FLAGS := -O1

$(BUILD_DIR)/src/gu/%.o: OPT_FLAGS := -O3
$(BUILD_DIR)/src/gt/%.o: OPT_FLAGS := -O3
$(BUILD_DIR)/src/rg/%.o: OPT_FLAGS := -O3
$(BUILD_DIR)/src/sp/%.o: OPT_FLAGS := -O3
$(BUILD_DIR)/src/sched/%.o: OPT_FLAGS := -O3
$(BUILD_DIR)/src/audio/%.o: OPT_FLAGS := -O3
$(BUILD_DIR)/src/libc/%.o: OPT_FLAGS := -O3
$(BUILD_DIR)/src/libc/b%.o: ASM_OPT_FLAGS := -O2 
$(BUILD_DIR)/src/libc/ll.o: MIPSISET := -mips3 -o32
$(BUILD_DIR)/src/libc/ll%.o: MIPSISET := -mips3 -o32
$(BUILD_DIR)/src/libc/ll.o: OPT_FLAGS := -O1
$(BUILD_DIR)/src/libc/ll%.o: OPT_FLAGS := -O1
$(BUILD_DIR)/src/os/exceptasm.o: MIPSISET := -mips3 -o32


#ifeq ($(TARGET_N64),1)
  TARGET_CFLAGS := -nostdinc -I include/2.0I -I include/2.0I/PR -DTARGET_N64 -D_FINALROM -DF3DEX_GBI -DNDEBUG
  CC_CFLAGS := -fno-builtin
#endif

INCLUDE_CFLAGS := -I include/2.0I -I include/2.0I/PR

# Check code syntax with host compiler
CC_CHECK := gcc -fsyntax-only $(CC_CFLAGS) $(TARGET_CFLAGS) $(INCLUDE_CFLAGS) -std=gnu90 -Wall -Wextra -Wno-format-security -DNON_MATCHING -DAVOID_UB $(VERSION_CFLAGS) $(GRUCODE_CFLAGS) -D_LANGUAGE_C -D_MIPS_SZINT=32 -D_MIPS_SZLONG=32
ASFLAGS = -v -Wab,-r4300_mul -non_shared -G 0 $(TARGET_CFLAGS) $(INCLUDE_CFLAGS) $(VERSION_CFLAGS) $(MIPSISET) $(ASM_OPT_FLAGS)
CFLAGS = -Wab,-r4300_mul -non_shared -G 0 -Xcpluscomm -fullwarn $(OPT_FLAGS) $(TARGET_CFLAGS) $(INCLUDE_CFLAGS) $(VERSION_CFLAGS) $(MIPSISET)
OBJCOPYFLAGS := --pad-to=0x800000 --gap-fill=0xFF
SYMBOL_LINKING_FLAGS := $(addprefix -R ,$(SEG_FILES))
LDFLAGS := -T undefined_syms.txt -T $(BUILD_DIR)/$(LD_SCRIPT) -Map $(BUILD_DIR)/sm64.$(VERSION).map --no-check-sections $(SYMBOL_LINKING_FLAGS)
ENDIAN_BITWIDTH := $(BUILD_DIR)/endian-and-bitwidth

ifeq ($(shell getconf LONG_BIT), 32)
  # Work around memory allocation bug in QEMU
  export QEMU_GUEST_BASE := 1
else
  # Ensure that gcc treats the code as 32-bit
  CC_CHECK += -m32
endif

####################### Other Tools #########################

SHA1SUM = sha1sum

###################### Dependency Check #####################

BINUTILS_VER_MAJOR := $(shell $(LD) --version | grep ^GNU | sed 's/^.* //; s/\..*//g')
BINUTILS_VER_MINOR := $(shell $(LD) --version | grep ^GNU | sed 's/^[^.]*\.//; s/\..*//g')
BINUTILS_DEPEND := $(shell expr $(BINUTILS_VER_MAJOR) \>= 2 \& $(BINUTILS_VER_MINOR) \>= 27)
ifeq ($(BINUTILS_DEPEND),0)
$(error binutils version 2.27 required, version $(BINUTILS_VER_MAJOR).$(BINUTILS_VER_MINOR) detected)
endif

######################## Targets #############################

#all: $(ROM)
#ifeq ($(COMPARE),1)
	#@$(SHA1SUM) -c $(TARGET).sha1 || (echo 'The build succeeded, but did not match the official ROM. This is expected if you are making changes to the game.\nTo silence this message, use "make COMPARE=0"'. && false)
#endif

clean:
	$(RM) -r $(BUILD_DIR_BASE)

distclean:
	$(RM) -r $(BUILD_DIR_BASE)
	./extract_assets.py --clean


$(BUILD_DIR)/%.o: %.c
	@$(CC_CHECK) -MMD -MP -MT $@ -MF $(BUILD_DIR)/$*.d $< 
	$(CC) -c $(CFLAGS) -o $@ $<


$(BUILD_DIR)/%.o: %.s
	$(AS) $(ASFLAGS) -o $@ $<

$(BUILD_DIR)/libultra_rom.a: $(O_FILES)
	$(AR) rcs -o $@ $(O_FILES)

#$(BUILD_DIR)/libultra.a: $(O_FILES)
  #$(LD) $()
default: $(BUILD_DIR)/libultra_rom.a



.PHONY: all clean distclean default diff test load libultra
.PRECIOUS: $(BUILD_DIR)/bin/%.elf $(SOUND_BIN_DIR)/%.ctl $(SOUND_BIN_DIR)/%.tbl $(SOUND_SAMPLE_TABLES) $(SOUND_BIN_DIR)/%.s $(BUILD_DIR)/%
.DELETE_ON_ERROR:

# Remove built-in rules, to improve performance
MAKEFLAGS += --no-builtin-rules

-include $(DEP_FILES)

print-% : ; $(info $* is a $(flavor $*) variable set to [$($*)]) @true
