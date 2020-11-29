# SPDX-License-Identifier: GPL-2.0
# ==========================================================================
# Build project
# ==========================================================================

########################################
# Sort file                            #
########################################

#
# Sort file
extra-y			:= $(sort $(extra-y))
lib-y			:= $(sort $(lib-y))

#
# Add file
extra-y			:= $(addprefix $(obj)/,$(extra-y))
lib-y			:= $(addprefix $(obj)/,$(lib-y))

########################################
# OBJ options                          #
########################################

# Backward compatibility
asflags-y  += $(EXTRA_AFLAGS)
ccflags-y  += $(EXTRA_CFLAGS)
cppflags-y += $(EXTRA_CPPFLAGS)
ldflags-y  += $(EXTRA_LDFLAGS)

orig_c_flags   = $(KBUILD_CPPFLAGS) $(KBUILD_CFLAGS) $(KBUILD_SUBDIR_CCFLAGS) \
                 $(ccflags-y) $(CFLAGS_$(basetarget).o)


_c_flags       = $(filter-out $(CFLAGS_REMOVE_$(basetarget).o), $(orig_c_flags))
_a_flags       = $(KBUILD_CPPFLAGS) $(KBUILD_AFLAGS) $(KBUILD_SUBDIR_ASFLAGS) \
                 $(asflags-y) $(AFLAGS_$(basetarget).o)
_cpp_flags     = $(KBUILD_CPPFLAGS) $(cppflags-y) $(CPPFLAGS_$(@F))


c_flags		= -Wp,-MD,$(depfile) $(NOSTDINC_FLAGS) -I $(INCLUDE)     \
		 	$(_c_flags) $(modkern_cflags)

a_flags		= -Wp,-MD,$(depfile) $(NOSTDINC_FLAGS) -I $(INCLUDE)     \
		 	$(_a_flags) $(modkern_aflags)

cpp_flags	= -Wp,-MD,$(depfile) $(NOSTDINC_FLAGS) -I $(INCLUDE)     \
		 	$(_cpp_flags)

ld_flags	= $(LDFLAGS) $(ldflags-y)


########################################
# Start build                          #
########################################

# Compile C sources (.c)
# ---------------------------------------------------------------------------

# Default is built-in, unless we know otherwise
modkern_cflags = $(KBUILD_CFLAGS_KERNEL) $(CFLAGS_KERNEL)
quiet_modtag := $(empty)   $(empty)

quiet_cmd_cc_s_c = $(ECHO_CC) $(quiet_modtag)  $@
	  cmd_cc_s_c = $(CC) $(c_flags) -fverbose-asm -S -o $@ $<

$(obj)/%.s: $(src)/%.c FORCE
	$(call if_changed_dep,cc_s_c)
quiet_cmd_cc_i_c = $(ECHO_CPP) $(quiet_modtag) $@
	  cmd_cc_i_c = $(CPP) $(c_flags)   -o $@ $<

$(obj)/%.i: $(src)/%.c FORCE
	$(call if_changed_dep,cc_i_c)

# C (.c) files
# The C file is compiled and updated dependency information is generated.
# (See cmd_cc_o_c + relevant part of rule_cc_o_c)

quiet_cmd_cc_o_c = $(ECHO_CC) $(quiet_modtag) $@
	  cmd_cc_o_c = $(CC) $(c_flags) -c -o $@ $<

define rule_cc_o_c
	$(call echo-cmd,cc_o_c) $(cmd_cc_o_c);				  \
	scripts/basic/fixdep $(depfile) $@ '$(call make-cmd,cc_o_c)' >    \
	                                              $(dot-target).tmp;  \
	rm -f $(depfile);						  \
	mv -f $(dot-target).tmp $(dot-target).cmd
endef

# Built-in and composite module parts
$(obj)/%.o: $(src)/%.c FORCE
	$(call if_changed_rule,cc_o_c)

quiet_cmd_cc_lst_c = MKLST   $@
      cmd_cc_lst_c = $(CC) $(c_flags) -g -c -o $*.o $< && \
		     $(CONFIG_SHELL) $(srctree)/scripts/makelst $*.o \
				     System.map $(OBJDUMP) > $@

$(obj)/%.lst: $(src)/%.c FORCE
	$(call if_changed_dep,cc_lst_c)

# Compile assembler sources (.S)
# ---------------------------------------------------------------------------

modkern_aflags := $(KBUILD_AFLAGS_KERNEL) $(AFLAGS_KERNEL)

quiet_cmd_as_s_S	= $(ECHO_CPP) $(quiet_modtag) $@
	  cmd_as_s_S	= $(CPP) $(a_flags) -o $@ $< 

$(obj)/%.s: $(src)/%.S FORCE
	$(call if_changed_dep,as_s_S)

quiet_cmd_as_o_S = $(ECHO_AS) $(quiet_modtag)  $@
cmd_as_o_S       = $(CC) $(a_flags) -c -o $@ $<

$(obj)/%.o: $(src)/%.S FORCE
	$(call if_changed_dep,as_o_S)

targets += $(real-objs-y) $(lib-y)
targets += $(extra-y) $(MAKECMDGOALS)

# Linker scripts preprocessor (.lds.S -> .lds)
# ---------------------------------------------------------------------------
quiet_cmd_cpp_lds_S = LDS     $@
      cmd_cpp_lds_S = $(CPP) $(cpp_flags) -P -C -U$(ARCH) \
	                     -D__ASSEMBLY__ -DLINKER_SCRIPT -o $@ $<

$(obj)/%.lds: $(src)/%.lds.S FORCE
	$(call if_changed_dep,cpp_lds_S)

# Build the compiled-in targets
# ---------------------------------------------------------------------------

# To build objects in subdirs, we need to descend into the directories
$(sort $(subdir-obj-y)): $(subdir-ym) ;
