# SPDX-License-Identifier: GPL-2.0
# ==========================================================================
# Build main
# ==========================================================================

########################################
# Sort file                            #
########################################

builtin-target := $(obj)/built-in.o

ifneq ($(strip $(obj-y) $(subdir-y)),)
always-y += $(builtin-target)
endif

########################################
# Start rule                           #
########################################

#
# Rule to compile a set of .o files into one .o file

quiet_cmd_link_o_target = $(ECHO_LD) $@
	  cmd_link_o_target = $(if $(strip $(obj-y)$(subdir-y)),\
		      $(LD) $(ld_flags) -r -o $@ $(obj-y), \
		      rm -f $@; $(AR) rcs$(KBUILD_ARFLAGS) $@)

$(builtin-target): $(obj-y) $(subdir-y) FORCE
	$(call if_changed,link_o_target)

targets += $(builtin-target)

#
# Rule to compile a set of .o files into one .a file
quiet_cmd_link_l_target = AR	$@
	  cmd_link_l_target = rm -f $@; $(AR) rcs$(KBUILD_ARFLAGS) $@ $(lib-y)

$(lib-target): $(lib-y) FORCE
	$(call if_changed,link_l_target)

targets += $(lib-target)
