# SPDX-License-Identifier: GPL-2.0
# ==========================================================================
# Build cust
# ==========================================================================

src := $(obj)

PHONY := _build
_build:

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

# cust-always-y += foo
# ... is a shorthand for
# cust += foo
# always-y  += foo
cust 		+= $(cust-always-y)
always-y 	+= $(cust-always-y)

########################################
# Sort files                           #
########################################

cust := $(sort $(cust))

########################################
# Filter files                         #
########################################

cust-single := $(foreach m,$(cust), \
			$(if $($(m)-obj-y),,$(m)))
			
cust-multi := $(foreach m,$(cust), \
			$(if $($(m)-obj-y),$(m)))

cust-objs	:= $(sort $(foreach m,$(cust),$($(m)-obj-y)))


########################################
# Cust options                         #
########################################

ifneq ($(cust-as),)
CUST_AS			:= $(cust-as)
endif

ifneq ($(cust-cc),)
CUST_CC			:= $(cust-cc)
endif

cust_a_flags	:= $(cust-asflags-y)
cust_c_flags	:= $(cust-ccflags-y)
cust_ld_flags	:= $(cust-ldflags-y)

########################################
# Add path                             #
########################################

cust-single := $(addprefix $(obj)/,$(cust-single))
cust-multi	:= $(addprefix $(obj)/,$(cust-multi))
cust-objs	:= $(addprefix $(obj)/,$(cust-objs))
always-y	:= $(addprefix $(obj)/,$(always-y))

########################################
# Compile O sources                    #
########################################

# Create executable from a single .c file
# host-csingle -> Executable
quiet_cmd_cust-csingle 	= $(ECHO_CUSTCC) $@
      cmd_cust-csingle	= $(CUST_CC) $(cust_c_flags) -o $@ $<
$(cust-single): $(obj)/%: $(src)/%.c FORCE
	$(call if_changed,host-csingle)

# Link an executable based on list of .o files, all plain c
# host-cmulti -> executable
quiet_cmd_host-cmulti	= $(ECHO_CUSTLD) $@
      cmd_host-cmulti	= $(CUST_LD) $(cust_ld_flags) -o $@ $^
$(cust-multi): $(cust-objs)
	$(call if_changed,host-cmulti)

########################################
# Compile C sources                    #
########################################

# #
# # Create single .s middle file from single .c file
# quiet_cmd_cc_s_c = $(ECHO_CUSTCC) $@
# 	  cmd_cc_s_c = $(CUST_CC) $(cust_c_flags) -fverbose-asm -S -o $@ $<
# $(obj)/%.s: $(src)/%.c FORCE
# 	$(call if_changed_dep,cc_s_c)

# #
# # Create single .s middle file from single .c file	
# quiet_cmd_cc_i_c = $(ECHO_CUSTCPP) $@
# 	  cmd_cc_i_c = $(CUST_CPP) $(cust_c_flags)   -o $@ $<
# $(obj)/%.i: $(src)/%.c FORCE
# 	$(call if_changed_dep,cc_i_c)

#
# Create single .s middle file from single .c file
quiet_cmd_cc_o_c = $(ECHO_CUSTCC) $@
	  cmd_cc_o_c = $(CUST_CC) $(cust_c_flags) -c -o $@ $<
$(obj)/%.o: $(src)/%.c FORCE
	$(call if_changed,cc_o_c)

# quiet_cmd_cc_lst_c = MKLST   $@
#       cmd_cc_lst_c = $(CUST_CC) $(cust_c_flags) -g -c -o $*.o $< && \
# 		     $(CONFIG_SHELL) $(srctree)/scripts/makelst $*.o \
# 				     System.map $(OBJDUMP) > $@
# $(obj)/%.lst: $(src)/%.c FORCE
# 	$(call if_changed,cc_lst_c)

########################################
# Compile assembler sources            #
########################################

# quiet_cmd_as_s_S	= $(ECHO_CUSTCPP) $@
# 	  cmd_as_s_S	= $(CUST_CPP) $(cust_a_flags) -o $@ $< 
# $(obj)/%.s: $(src)/%.S FORCE
# 	$(call if_changed_dep,as_s_S)

quiet_cmd_as_o_S = $(ECHO_CUSTAS) $@
	  cmd_as_o_S = $(CUST_AS) $(cust_a_flags) -o $@ $<
$(obj)/%.o: $(src)/%.S FORCE
	$(call if_changed,as_o_S)

targets += 

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

