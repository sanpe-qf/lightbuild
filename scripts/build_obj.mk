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
targets			:= $(sort $(targets))
obj-y			:= $(sort $(obj-y))
lib-y			:= $(sort $(lib-y))
subdir-obj-y	:= $(sort $(subdir-obj-y))
real-objs-y		:= $(sort $(real-objs-y))
obj-dirs		:= $(sort $(obj-dirs))
subdir			:= $(sort $(subdir))

#
# Add file
extra-y			:= $(addprefix $(obj)/,$(extra-y))
targets			:= $(addprefix $(obj)/,$(targets))
obj-y			:= $(addprefix $(obj)/,$(obj-y))
lib-y			:= $(addprefix $(obj)/,$(lib-y))
subdir-obj-y	:= $(addprefix $(obj)/,$(subdir-obj-y))
real-objs-y		:= $(addprefix $(obj)/,$(real-objs-y))
subdir-ym		:= $(addprefix $(obj)/,$(subdir-ym))
obj-dirs		:= $(addprefix $(obj)/,$(obj-dirs))
subdir			:= $(addprefix $(obj)/,$(subdir-ym))

########################################
# OBJ options                          #
########################################

orig_c_flags   = $(KBUILD_CPPFLAGS) $(KBUILD_CFLAGS) $(KBUILD_SUBDIR_CCFLAGS) \
                 $(ccflags-y) $(CFLAGS_$(basetarget).o)
_c_flags       = $(filter-out $(CFLAGS_REMOVE_$(basetarget).o), $(orig_c_flags))
_a_flags       = $(KBUILD_CPPFLAGS) $(KBUILD_AFLAGS) $(KBUILD_SUBDIR_ASFLAGS) \
                 $(asflags-y) $(AFLAGS_$(basetarget).o)
_cpp_flags     = $(KBUILD_CPPFLAGS) $(cppflags-y) $(CPPFLAGS_$(@F))

# If building the kernel in a separate objtree expand all occurrences
# of -Idir to -I$(srctree)/dir except for absolute paths (starting with '/').

ifeq ($(KBUILD_SRC),)
__c_flags	= $(_c_flags)
__a_flags	= $(_a_flags)
__cpp_flags	= $(_cpp_flags)
else
# -I$(obj) locates generated .h files
# $(call addtree,-I$(obj)) locates .h files in srctree, from generated .c files
#   and locates generated .h files
# FIXME: Replace both with specific CFLAGS* statements in the makefiles
__c_flags	= $(call addtree,-I$(obj)) $(call flags,_c_flags)
__a_flags	= $(call flags,_a_flags)
__cpp_flags	= $(call flags,_cpp_flags)
endif

c_flags		= -Wp,-MD,$(depfile) $(NOSTDINC_FLAGS) $(INCLUDE)     \
		 	$(__c_flags) $(modkern_cflags)

a_flags		= -Wp,-MD,$(depfile) $(NOSTDINC_FLAGS) $(INCLUDE)     \
		 	$(__a_flags) $(modkern_aflags)

cpp_flags	= -Wp,-MD,$(depfile) $(NOSTDINC_FLAGS) $(INCLUDE)     \
		 	$(__cpp_flags)

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

quiet_cmd_as_o_S = AS $(quiet_modtag)  $@
cmd_as_o_S       = $(CC) $(a_flags) -c -o $@ $<

$(obj)/%.o: $(src)/%.S FORCE
	$(call if_changed_dep,as_o_S)

targets += $(real-objs-y) $(lib-y)
targets += $(extra-y) $(MAKECMDGOALS) $(always)

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

#
# Rule to compile a set of .o files into one .o file
ifdef builtin-target
quiet_cmd_link_o_target = LD $@
# If the list of objects to link is empty, just create an empty built-in.o
cmd_link_o_target = $(if $(strip $(obj-y)),\
		      $(LD) $(ld_flags) -r -o $@ $(filter $(obj-y), $^), \
		      rm -f $@; $(AR) rcs$(KBUILD_ARFLAGS) $@)

$(builtin-target): $(obj-y) FORCE
	$(call if_changed,link_o_target)

targets += $(builtin-target)
endif # builtin-target

#
# Rule to compile a set of .o files into one .a file
ifdef lib-target
quiet_cmd_link_l_target = AR	$@
	  cmd_link_l_target = rm -f $@; $(AR) rcs$(KBUILD_ARFLAGS) $@ $(lib-y)

$(lib-target): $(lib-y) FORCE
	$(call if_changed,link_l_target)

targets += $(lib-target)
endif
