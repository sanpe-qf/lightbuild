# SPDX-License-Identifier: GPL-2.0
# ==========================================================================
# Build nasm
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

#
# Include host rule
include $(BUILD_HOME)/modules/host_rule.mk

########################################
# NASM options                         #
########################################

nasm_flags += -I $(src) $(INCLUDE)

########################################
# Start build                          #
########################################

# Create executable from a single .S file
# nasm-single -> Executable
quiet_cmd_nasm-single 	= $(ECHO_NASM)  $@
      cmd_nasm-single	= $(NASM) $(nasm_flags) -o $@ $< 
$(nasm-single): $(obj)/%: $(src)/%.S FORCE
	$(call if_changed,nasm-single)

quiet_cmd_nasm-multi 	= $(ECHO_NASM)  $@
      cmd_nasm-multi	= $(NASM) $(nasm_flags) -o $@ $< 
$(nasm-multi): $(obj)/%: $(src)/%.S FORCE
	$(call if_changed,nasm-multi)


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