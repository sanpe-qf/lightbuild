# SPDX-License-Identifier: GPL-2.0
# ==========================================================================
# Main build system
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
# Filter file                          #
########################################

obj-file-y		:= $(filter-out $(subdir-y),$(obj-y))

########################################
# Sort file                            #
########################################

#
# Sort file
obj-file-y		:= $(sort $(obj-file-y))
extra-y			:= $(sort $(extra-y))
lib-y			:= $(sort $(lib-y))

obj-file-y		:= $(patsubst %/, %/built-in.o, $(obj-file-y))

#
# Add file
obj-file-y		:= $(addprefix $(obj)/,$(obj-file-y))
extra-y			:= $(addprefix $(obj)/,$(extra-y))
lib-y			:= $(addprefix $(obj)/,$(lib-y))

# # Libraries are always collected in one lib file.
# # Filter out objects already built-in

# lib-y := $(filter-out $(obj-y), $(sort $(lib-y)))

# # Subdirectories we need to descend into

# # $(subdir-obj-y) is the list of objects in $(obj-y) which uses dir/ to
# # tell kbuild to descend
# subdir-obj-y := $(filter %/built-in.o, $(obj-y))

# # $(obj-dirs) is a list of directories that contain object files
# obj-dirs := $(dir $(subdir-obj-y))

# # Replace multi-part objects by their individual parts, look at local dir only
# real-objs-y := $(foreach m, $(filter-out $(subdir-obj-y), $(obj-y)), $(if $(strip $($(m:.o=-objs)) $($(m:.o=-y))),$($(m:.o=-objs)) $($(m:.o=-y)),$(m))) $(extra-y)

ifneq ($(strip $(obj-y) $(obj-m) $(obj-) $(subdir-m) $(lib-target)),)
builtin-target := $(obj)/built-in.o
always-y += $(builtin-target)
endif

########################################
# build rule                           #
########################################

#
# Active rules: assembly to bin
include $(BUILD_HOME)/auxiliary/build_bin.mk

#
# Passive rule
include $(BUILD_HOME)/main/main_rule.mk

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

targets := $(wildcard $(sort $(targets)))
cmd_files := $(wildcard $(foreach f,$(targets),$(dir $(f)).$(notdir $(f)).cmd))

ifneq ($(cmd_files),)
  include $(cmd_files)
endif

.PHONY: $(PHONY)
