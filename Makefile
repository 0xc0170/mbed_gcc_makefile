#
# File: Makefile for mbed on KL25Z (ARM GCC)
#
# Copyright (c) 6.2013, 0xc0170
#
# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What The Fuck You Want
# To Public License, Version 2, as published by Sam Hocevar. See
# http://www.wtfpl.net/ for more details.

# toolchain specific
TOOLCHAIN = arm-none-eabi-
CC = $(TOOLCHAIN)gcc
CXX = $(TOOLCHAIN)g++
AS = $(TOOLCHAIN)gcc -x assembler-with-cpp
LD = $(TOOLCHAIN)gcc
OBJCP = $(TOOLCHAIN)objcopy
AR = $(TOOLCHAIN)ar

# application specific
CPU = cortex-m0
INSTRUCTION_MODE = thumb
TARGET = mbed
TARGET_EXT = elf
LD_SCRIPT = mbed/TARGET_KL25Z/TOOLCHAIN_GCC_ARM/MKL25Z4.ld

CC_SYMBOLS = -DTARGET_KL25Z -DTOOLCHAIN_GCC_ARM -DNDEBUG

LIB_DIRS = mbed/TARGET_KL25Z/TOOLCHAIN_GCC_ARM
LIBS = -lmbed -lstdc++ -lsupc++ -lm -lgcc -lc -lnosys


MBED_OBJ = mbed/TARGET_KL25Z/TOOLCHAIN_GCC_ARM/cmsis_nvic.o
MBED_OBJ += mbed/TARGET_KL25Z/TOOLCHAIN_GCC_ARM/startup_MKL25Z4.o
MBED_OBJ += mbed/TARGET_KL25Z/TOOLCHAIN_GCC_ARM/stdio.o
MBED_OBJ += mbed/TARGET_KL25Z/TOOLCHAIN_GCC_ARM/system_MKL25Z4.o

# directories
INC_DIRS = mbed mbed/TARGET_KL25Z mbed/TARGET_KL25Z/TOOLCHAIN_GCC_ARM

SRC_DIRS = mbed mbed/TARGET_KL25Z mbed/TARGET_KL25Z/TOOLCHAIN_GCC_ARM .

OUT_DIR = out

INC_DIRS_F = -I. $(patsubst %, -I%, $(INC_DIRS))

ifeq ($(strip $(OUT_DIR)), )
	OBJ_FOLDER =
else
	OBJ_FOLDER = $(strip $(OUT_DIR))/
endif

COMPILER_OPTIONS  = -g -ggdb -Os -Wall -fno-strict-aliasing -fno-rtti
COMPILER_OPTIONS += -ffunction-sections -fdata-sections -fno-exceptions -fno-delete-null-pointer-checks
COMPILER_OPTIONS += -fmessage-length=0 -fno-builtin -m$(INSTRUCTION_MODE)
COMPILER_OPTIONS += -mcpu=$(CPU) -MD -MP $(CC_SYMBOLS)

DEPEND_OPTS = -MF $(OBJ_FOLDER)$(@F:.o=.d)

# Flags
CFLAGS = $(COMPILER_OPTIONS) $(DEPEND_OPTS) $(INC_DIRS_F) -std=gnu99 -c

CXXFLAGS = $(COMPILER_OPTIONS) $(DEPEND_OPTS) $(INC_DIRS_F) -std=gnu++98 -c

ASFLAGS = $(COMPILER_OPTIONS) $(INC_DIRS_F) -c

# Linker options
LD_OPTIONS = -mcpu=$(CPU) -m$(INSTRUCTION_MODE) -Os -L $(LIB_DIRS) -T $(LD_SCRIPT) $(INC_DIRS_F)
LD_OPTIONS += -specs=nano.specs -u _printf_float -u _scanf_float
LD_OPTIONS += -Wl,-Map=$(OBJ_FOLDER)$(TARGET).map,--gc-sections

RM = rm -rf

USER_OBJS =
C_SRCS =
S_SRCS =
C_OBJS =
S_OBJS =

# All source/object files inside SRC_DIRS
C_SRCS := $(foreach dir,$(SRC_DIRS),$(wildcard $(dir)/*.c))
C_OBJS := $(patsubst %.c,$(OBJ_FOLDER)%.o,$(notdir $(C_SRCS)))

CPP_SRCS := $(foreach dir,$(SRC_DIRS),$(wildcard $(dir)/*.cpp))
CPP_OBJS := $(patsubst %.cpp,$(OBJ_FOLDER)%.o,$(notdir $(CPP_SRCS)))

S_SRCS := $(foreach dir,$(SRC_DIRS),$(wildcard $(dir)/*.s))
S_OBJS := $(patsubst %.s,$(OBJ_FOLDER)%.o,$(notdir $(S_SRCS)))

VPATH := $(SRC_DIRS)

$(OBJ_FOLDER)%.o : %.c
	@echo 'Building file: $(@F)'
	@echo 'Invoking: MCU C Compiler'
	$(CC) $(CFLAGS) $< -o $@
	@echo 'Finished building: $(@F)'
	@echo ' '

$(OBJ_FOLDER)%.o : %.cpp
	@echo 'Building file: $(@F)'
	@echo 'Invoking: MCU C++ Compiler'
	$(CXX) $(CXXFLAGS) $< -o $@
	@echo 'Finished building: $(@F)'
	@echo ' '

$(OBJ_FOLDER)%.o : %.s
	@echo 'Building file: $(@F)'
	@echo 'Invoking: MCU Assembler'
	$(AS) $(ASFLAGS) $< -o $@
	@echo 'Finished building: $(@F)'
	@echo ' '

all: create_outputdir $(OBJ_FOLDER)$(TARGET).$(TARGET_EXT) print_size

create_outputdir:
	$(shell mkdir $(OBJ_FOLDER) 2>/dev/null)

# Tool invocations
$(OBJ_FOLDER)$(TARGET).$(TARGET_EXT): $(LD_SCRIPT) $(C_OBJS) $(CPP_OBJS) $(S_OBJS) $(MBED_OBJ)
	@echo 'Building target: $@'
	@echo 'Invoking: MCU Linker'
	$(LD) $(LD_OPTIONS) $(CPP_OBJS) $(C_OBJS) $(S_OBJS) $(MBED_OBJ) $(LIBS) -o $(OBJ_FOLDER)$(TARGET).$(TARGET_EXT)
	@echo 'Finished building target: $@'
	@echo ' '

# Other Targets
clean:
	@echo 'Removing entire out directory'
	$(RM) $(TARGET).$(TARGET_EXT) $(TARGET).bin $(TARGET).map $(OBJ_FOLDER)*.* $(OBJ_FOLDER)
	@echo ' '

print_size:
	@echo 'Printing size'
	arm-none-eabi-size --totals $(OBJ_FOLDER)$(TARGET).$(TARGET_EXT)
	arm-none-eabi-objcopy -O srec $(OBJ_FOLDER)$(TARGET).$(TARGET_EXT) $(OBJ_FOLDER)$(TARGET).s19
	@echo ' '

.PHONY: all clean print_size
