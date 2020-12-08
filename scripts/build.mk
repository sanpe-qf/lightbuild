# SPDX-License-Identifier: GPL-2.0
# ==========================================================================
# Build sub system
# ==========================================================================
src := $(obj)

PHONY := _build
_build:

#
# Include Buildsystem function
include $(BUILD_HOME)/include/define.mk

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

INCLUDE		:= $(addprefix $(obj)/,$(include-y)) $(INCLUDE)
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
# elf-y -> elf
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

# bin-always-y += foo
# ... is a shorthand for
# bin += foo
# always-y  += foo
bin 		+= $(bin-always-y)

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
subdir-y		:= $(obj-y) $(subdir-y)
subdir-y		:= $(strip $(sort $(subdir-y)))
subdir-y		:= $(filter %/, $(subdir-y))
subdir-y		:= $(patsubst %/,%,$(subdir-y))
subdir-y		:= $(addprefix $(obj)/,$(subdir-y))

export SUBDIR_ASFLAGS := $(SUBDIR_ASFLAGS) $(subdir-asflags-y)
export SUBDIR_CCFLAGS := $(SUBDIR_CCFLAGS) $(subdir-ccflags-y)

########################################
# basic rule                           #
########################################

ifneq ($(obj-y),)
rules += rule_main
endif

#
# Independent rules: assembly to bin
rule_main:
	$(Q)$(MAKE) $(build_main)=$(obj)

########################################
# Nasm Module                          #
########################################

ifneq ($(nasm),)
rules += rule_nasm
endif

#
# Independent rules: assembly to bin
rule_nasm:
	$(Q)$(MAKE) $(build_nasm)=$(obj)

########################################
# Cust Module                          #
########################################

ifneq ($(cust),)
rules += rule_cust
endif

#
# Independent rules: cust rules to elf
rule_cust:
	$(Q)$(MAKE) $(build_cust)=$(obj)

########################################
# Host Module                          #
########################################

ifneq ($(hostprogs),)
rules += rule_host
endif

#
# Independent rules: hostprogs ruled to rules
rule_host:
	$(Q)$(MAKE) $(build_host)=$(obj)

########################################
# Start build                          #
########################################

_build: $(rules) $(subdir-y) $(always-y) 

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

ifneq ($(cmd_files),)
  include $(cmd_files)
endif

.PHONY: $(PHONY)
