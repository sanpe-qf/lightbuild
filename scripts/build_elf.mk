# SPDX-License-Identifier: GPL-2.0
# ==========================================================================
# Build elf
# ==========================================================================

########################################
# Sort file                            #
########################################

obj-y		:= $(sort $(obj-y))
obj-y		:= $(addprefix $(obj)/,$(obj-y))

elf-target	:= $(sort $(elf))
elf-target	:= $(addprefix $(obj)/,$(elf-target))

#
# Rule to compile a set of .o files into one .o file

quiet_cmd_link_o_target = $(ECHO_LD) $@
	  cmd_link_o_target = $(if $(strip $(obj-y)),\
		      $(LD) $(ld_flags) -r -o $@ $(filter $(obj-y), $^), \
		      rm -f $@; $(AR) rcs$(KBUILD_ARFLAGS) $@)

$(elf-target): $(obj-y) FORCE
	$(call if_changed,link_o_target)

targets += $(elf-target)