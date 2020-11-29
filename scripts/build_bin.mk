# SPDX-License-Identifier: GPL-2.0
# ==========================================================================
# Make bin
# ==========================================================================

########################################
# Sort files                           #
########################################

bin-target	:= $(sort $(bin))
bin-target	:= $(addprefix $(obj)/,$(bin-target))

ifndef bin_flags
bin_flags	:= -O binary -j .text -j .rodata 
endif 

########################################
# Start build                          #
########################################

# Create executable from a single .c file
# host-csingle -> Executable
quiet_cmd_build_bin = $(ECHO_BIN)  $@
      cmd_build_bin	= $(OBJCOPY) $(bin_flags) $@ $< 
$(bin-target): $(elf-target) FORCE
	$(call if_changed,build_bin)

targets += $(bin-target) 