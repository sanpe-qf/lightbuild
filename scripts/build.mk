# SPDX-License-Identifier: GPL-2.0
# ==========================================================================
# Build sub system
# ==========================================================================
src := $(obj)

PHONY := _build
_build:

#
# Init parameters
obj-y :=
obj-m :=
lib-y :=
lib-m :=
always :=
always-y :=
always-m :=
targets :=
subdir-y :=
subdir-m :=
EXTRA_AFLAGS   :=
EXTRA_CFLAGS   :=
EXTRA_CPPFLAGS :=
EXTRA_LDFLAGS  :=
asflags-y  :=
ccflags-y  :=
cppflags-y :=
ldflags-y  :=
subdir-asflags-y :=
subdir-ccflags-y :=

# flags that take effect in current and sub directories
KBUILD_AFLAGS += $(subdir-asflags-y)
KBUILD_CFLAGS += $(subdir-ccflags-y)

#
# Include Build function
include $(BUILD_HOME)/build_def.mk

#
# Include Buildsystem function
include $(BUILD_HOME)/define.mk

#
# Read auto.conf if it exists, otherwise ignore
-include $(MAKE_HOME)/include/config/auto.conf

#
# Include obj makefile
build-dir := $(if $(filter /%,$(src)),$(src),$(MAKE_HOME)/$(src))
build-file := $(if $(wildcard $(build-dir)/Kbuild),$(build-dir)/Kbuild,$(build-dir)/Makefile)
include $(build-file)

########################################
# Start include                        #
########################################

INCLUDE		+= $(addprefix $(obj)/,$(include-y))
export INCLUDE

########################################
# Old compatible                       #
########################################

#
# always -> always-y
ifneq ($(always),)
$(warning 'always' is deprecated. Please use 'always-y' instead)
always-y += $(always)
endif

#
# exe-y -> exe
ifneq ($(elf-y),)
$(warning 'elf-y' is deprecated. Please use 'elf' instead)
elf  += $(elf-y)
endif

#
# hostprog-y -> hostprog
ifneq ($(hostprogs-y),)
$(warning 'hostprogs-y' is deprecated. Please use 'hostprogs' instead)
hostprogs  += $(hostprogs-y)
endif

########################################
# Always build                         #
########################################


# elf-always-y += foo
# ... is a shorthand for
# elf += foo
# always-y  += foo
elf 		+= $(elf-always-y)
always-y 	+= $(elf-always-y)

# lib-always-y += foo
# ... is a shorthand for
# lib += foo
# always-y  += foo
lib 		+= $(lib-always-y)
always-y 	+= $(lib-always-y)

# bin-always-y += foo
# ... is a shorthand for
# bin += foo
# always-y  += foo
bin 		+= $(bin-always-y)
always-y 	+= $(bin-always-y)

# nasm-always-y += foo
# ... is a shorthand for
# nasm += foo
nasm 		+= $(nasm-always-y)

# cust-always-y += foo
# ... is a shorthand for
# cust += foo
cust 		+= $(cust-always-y)

# hostprogs-always-y += foo
# ... is a shorthand for
# hostprogs += foo
hostprogs 	+= $(hostprogs-always-y)

always-y	:= $(addprefix $(obj)/,$(always-y))
targets 	+= $(always-y)

########################################
# filter subdir                        #
########################################

#
# filter subdir 
subdir-y		:= $(obj-y)
subdir-y		:= $(strip $(sort $(subdir-y)))
subdir-y		:= $(filter %/, $(subdir-y))
subdir-y		:= $(patsubst %/,%,$(subdir-y))
subdir-y		:= $(addprefix $(obj)/,$(subdir-y))

export SUBDIR_ASFLAGS := $(SUBDIR_ASFLAGS) $(subdir-asflags-y)
export SUBDIR_CCFLAGS := $(SUBDIR_CCFLAGS) $(subdir-ccflags-y)


# Libraries are always collected in one lib file.
# Filter out objects already built-in

lib-y := $(filter-out $(obj-y), $(sort $(lib-y)))

# Subdirectories we need to descend into

# $(subdir-obj-y) is the list of objects in $(obj-y) which uses dir/ to
# tell kbuild to descend
subdir-obj-y := $(filter %/built-in.o, $(obj-y))

# $(obj-dirs) is a list of directories that contain object files
obj-dirs := $(dir $(subdir-obj-y))

# Replace multi-part objects by their individual parts, look at local dir only
real-objs-y := $(foreach m, $(filter-out $(subdir-obj-y), $(obj-y)), $(if $(strip $($(m:.o=-objs)) $($(m:.o=-y))),$($(m:.o=-objs)) $($(m:.o=-y)),$(m))) $(extra-y)

########################################
# basic rule                           #
########################################

#
# Passive rule
include $(BUILD_HOME)/build_basic.mk

########################################
# basic rule                           #
########################################

#
# Passive rule
include $(BUILD_HOME)/build_main.mk

########################################
# lib Module                           #
########################################

#
# Active rule: object to lib
include $(BUILD_HOME)/build_lib.mk

########################################
# Exe Module                           #
########################################

#
# Passive rule: object to elf
include $(BUILD_HOME)/build_elf.mk

########################################
# Bin Module                           #
########################################

#
# Active rules: assembly to bin
include $(BUILD_HOME)/build_bin.mk

########################################
# Nasm Module                          #
########################################

ifneq ($(nasm),)
rules += rule_nasm
endif

#
# Independent rules: assembly to bin
rule_nasm:
	$(Q)$(MAKE) -f $(BUILD_HOME)/build_nasm.mk obj=$(obj)

########################################
# Cust Module                          #
########################################

ifneq ($(cust),)
rules += rule_cust
endif

#
# Independent rules: cust rules to elf
rule_cust:
	$(Q)$(MAKE) -f $(BUILD_HOME)/build_cust.mk

########################################
# Host Module                          #
########################################

ifneq ($(hostprogs),)
rules += rule_host
endif

#
# Independent rules: hostprogs ruled to rules
rule_host:
	$(Q)$(MAKE) -f $(BUILD_HOME)/build_host.mk

########################################
# Start build                          #
########################################

_build: $(rules) $(always-y) $(subdir-y)

########################################
# Descending build                     #
########################################

PHONY += $(subdir-y)
$(subdir-y):
	$(Q)$(MAKE) $(build)=$@

########################################
# Start FORCE                          #
########################################

PHONY += FORCE 
FORCE:
	
# Read all saved command lines and dependencies for the $(targets) we
# may be building above, using $(if_changed{,_dep}). As an
# optimization, we don't need to read them if the target does not
# exist, we will rebuild anyway in that case.

targets := $(wildcard $(sort $(targets)))
cmd_files := $(wildcard $(foreach f,$(targets),$(dir $(f)).$(notdir $(f)).cmd))

ifneq ($(cmd_files),)
  include $(cmd_files)
endif

.PHONY: $(PHONY)