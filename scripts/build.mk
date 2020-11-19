# SPDX-License-Identifier: GPL-2.0
# ==========================================================================
# Build sub system
# ==========================================================================
src := $(obj)

PHONY := _build
_build:

#
# Read auto.conf if it exists, otherwise ignore
-include $(MAKE_HOME)/config/auto.conf

#
# Include obj makefile
build-dir := $(if $(filter /%,$(src)),$(src),$(MAKE_HOME)/$(src))
build-file := $(if $(wildcard $(build-dir)/Kbuild),$(build-dir)/Kbuild,$(build-dir)/Makefile)
include $(build-file)

#
# Include Buildsystem function
include $(BUILD_HOME)/define.mk

#
# Include Build function
include $(BUILD_HOME)/build_def.mk

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
ifneq ($(exe-y),)
$(warning 'exe-y' is deprecated. Please use 'exe' instead)
exe  += $(exe-y)
endif

#
# hostprog-y -> hostprog
ifneq ($(hostprogs-y),)
$(warning 'hostprogs-y' is deprecated. Please use 'hostprogs' instead)
hostprogs  += $(hostprogs-y)
endif

########################################
# Always build                        #
########################################

# hostprogs-always-y += foo
# ... is a shorthand for
# hostprogs += foo
# always-y  += foo
hostprogs 	+= $(hostprogs-always-y) $(hostprogs-always-m)
always-y 	+= $(hostprogs-always-y) $(hostprogs-always-m)

always-y	:= $(addprefix $(obj)/,$(always-y))

########################################
# filter subdir                        #
########################################

subdir-y	:= $(patsubst %/,%,$(filter %/, $(obj-y)))
subdir-y	:= $(sort $(subdir-y))

# Backward compatibility
asflags-y  += $(EXTRA_AFLAGS)
ccflags-y  += $(EXTRA_CFLAGS)
cppflags-y += $(EXTRA_CPPFLAGS)
ldflags-y  += $(EXTRA_LDFLAGS)

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
# OBJ Module                           #
########################################

include $(BUILD_HOME)/build_obj.mk

########################################
# Exe Module                           #
########################################

#
# obj *.o -> exe
ifneq ($(exe-y),)
include $(BUILD_HOME)/build_obj.m
endif

########################################
# Host Module                          #
########################################

ifneq ($(hostprogs) $(always),)
include $(BUILD_HOME)/build_host.mk
endif

########################################
# Start build                          #
########################################

_build: $(always-y) $(subdir-y)

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