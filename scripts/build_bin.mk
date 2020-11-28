# SPDX-License-Identifier: GPL-2.0
# ==========================================================================
# Make bin
# ==========================================================================
 
bin := $(sort $(bin))


nasm-single	:= $(addprefix $(obj)/,$(nasm-single))


########################################
# Start build                          #
########################################

# Create executable from a single .c file
# host-csingle -> Executable
quiet_cmd_build_bin = $(ECHO_BIN)  $@
      cmd_build_bin	= $(OBJDUMP) $(nasm_flags) -o $@ $< 
$(nasm-single): $(obj)/%: $(src)/%.S FORCE
	$(call if_changed,build_bin)