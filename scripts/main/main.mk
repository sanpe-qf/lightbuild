# SPDX-License-Identifier: GPL-2.0
# ==========================================================================
# Main build system
# ==========================================================================
src := $(obj)

PHONY := _build
_build:

#
# Init parameters
obj-y :=
obj-m :=
lib-y :=
lib-m :=
always :=
always-y :=
always-m :=
targets :=
subdir-y :=
subdir-m :=
EXTRA_AFLAGS   :=
EXTRA_CFLAGS   :=
EXTRA_CPPFLAGS :=
EXTRA_LDFLAGS  :=
asflags-y  :=
ccflags-y  :=
cppflags-y :=
ldflags-y  :=

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
# Include main rule
include $(BUILD_HOME)/main/main_rule.mk

########################################
# OBJ options                          #
########################################

include_file := $(addprefix -I ,$(INCLUDE))

ifneq (asflags-y,)
asflags-y	:= $(asflags-sub-y)
endif

ifneq (ccflags-y,)
ccflags-y	:= $(ccflags-sub-y)
endif

ifneq (cppflags-y,)
cppflags-y	:= $(cppflags-sub-y)
endif

ifneq (ldflags-y,)
ldflags-y	:= $(ldflags-sub-y)
endif

export asflags-sub-y ccflags-sub-y cppflags-sub-y asflags-sub-y ldflags-sub-y


a_flags		= -Wp,-MD,$(depfile) $(include_file) $(asflags-y)

c_flags		= -Wp,-MD,$(depfile) $(include_file) $(ccflags-y)

cpp_flags	= -Wp,-MD,$(depfile) $y(include_file) $(cppflags-y)

ld_flags	= $(LDFLAGS) $(ldflags-y)

########################################
# Start rule                           #
########################################

#
# Active rules: assembly to bin
include $(BUILD_HOME)/auxiliary/bin.mk

# Compile C sources (.c)
# ---------------------------------------------------------------------------

quiet_cmd_cc_s_c = $(ECHO_CC) $@
	  cmd_cc_s_c = $(CC) $(c_flags) -fverbose-asm -S -o $@ $<
$(obj)/%.s: $(src)/%.c FORCE
	$(call if_changed_dep,cc_s_c)

quiet_cmd_cc_i_c = $(ECHO_CPP) $@
	  cmd_cc_i_c = $(CPP) $(c_flags)   -o $@ $<
$(obj)/%.i: $(src)/%.c FORCE
	$(call if_changed_dep,cc_i_c)

# C (.c) files
# The C file is compiled and updated dependency information is generated.
# (See cmd_cc_o_c + relevant part of rule_cc_o_c)

quiet_cmd_cc_o_c = $(ECHO_CC) $@
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
	$(call if_changed_dep,cc_o_c)

quiet_cmd_cc_lst_c = MKLST   $@
      cmd_cc_lst_c = $(CC) $(c_flags) -g -c -o $*.o $< && \
		     $(CONFIG_SHELL) $(srctree)/scripts/makelst $*.o \
				     System.map $(OBJDUMP) > $@

$(obj)/%.lst: $(src)/%.c FORCE
	$(call if_changed_dep,cc_lst_c)

# Compile assembler sources (.S)
# ---------------------------------------------------------------------------

quiet_cmd_as_s_S	= $(ECHO_CPP) $@
	  cmd_as_s_S	= $(CPP) $(a_flags) -o $@ $< 

$(obj)/%.s: $(src)/%.S FORCE
	$(call if_changed_dep,as_s_S)

quiet_cmd_as_o_S = $(ECHO_AS) $@
cmd_as_o_S       = $(AS) $(a_flags) -c -o $@ $<

$(obj)/%.o: $(src)/%.S FORCE
	$(call if_changed_dep,as_o_S)


# Linker scripts preprocessor (.lds.S -> .lds)
# ---------------------------------------------------------------------------
quiet_cmd_cpp_lds_S = LDS $@
      cmd_cpp_lds_S = $(CPP) $(cpp_flags) -P -C -U$(ARCH) \
	                     -D__ASSEMBLY__ -DLINKER_SCRIPT -o $@ $<

$(obj)/%.lds: $(src)/%.lds.S FORCE
	$(call if_changed_dep,cpp_lds_S)

$(obj-subfile):$(subdir-y)
#
# Rule to compile a set of .o files into one .o file
quiet_cmd_link_o_target = $(ECHO_LD) $@
	  cmd_link_o_target = $(if $(strip $(obj-file) $(obj-subfile) $(subdir-y)),\
		      $(LD) $(ld_flags) -r -o $@ $(obj-file) $(obj-subfile), \
		      rm -f $@; $(AR) rcs$(KBUILD_ARFLAGS) $@)
$(builtin-target): $(obj-file) $(obj-subfile) FORCE
	$(call if_changed,link_o_target)

#
# Rule to compile a set of .o files into one .a file
quiet_cmd_link_l_target = AR	$@
	  cmd_link_l_target = rm -f $@; $(AR) rcs$(KBUILD_ARFLAGS) $@ $(lib-y)
$(lib-target): $(lib-y) FORCE
	$(call if_changed,link_l_target)

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
