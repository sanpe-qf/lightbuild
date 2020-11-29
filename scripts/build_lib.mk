# SPDX-License-Identifier: GPL-2.0
# ==========================================================================
# Build lib
# ==========================================================================


#
# Rule to compile a set of .o files into one .a file
quiet_cmd_link_l_target = AR	$@
	  cmd_link_l_target = rm -f $@; $(AR) rcs$(KBUILD_ARFLAGS) $@ $(lib-y)

$(lib-target): $(lib-y) FORCE
	$(call if_changed,link_l_target)

targets += $(lib-target)