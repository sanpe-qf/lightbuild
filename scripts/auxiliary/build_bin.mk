# SPDX-License-Identifier: GPL-2.0
# ==========================================================================
# Make bin
# ==========================================================================

########################################
# Sort files                           #
########################################

bin	:= $(sort $(bin))

########################################
# Filter files                         #
########################################

bin-objs	:= $(sort $(foreach m,$(bin),$($(m)-obj-y)))

########################################
# Add path                             #
########################################

bin	:= $(addprefix $(obj)/,$(bin))
bin-objs	:= $(addprefix $(obj)/,$(bin-objs))

########################################
# Cust options                         #
########################################

bin_flags	+= $(bin-flags-y)

ifeq ($(bin_flags),)
bin_flags	:= -O binary
endif 

########################################
# Start build                          #
########################################

# Create executable from a single .c file
# host-csingle -> Executable
quiet_cmd_build_bin = $(ECHO_BIN)  $@
      cmd_build_bin	= $(OBJCOPY) $(bin_flags) $(bin-objs) $@ 
$(bin): $(bin-objs) FORCE
	$(call if_changed,build_bin)

targets += $(bin)