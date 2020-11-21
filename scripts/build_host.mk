# SPDX-License-Identifier: GPL-2.0
# ==========================================================================
# Build host
# ==========================================================================

########################################
# Sort files                           #
########################################

hostprogs := $(sort $(hostprogs))
host-cshlib := $(sort $(hostlibs-y) $(hostlibs-m))
host-cxxshlib := $(sort $(hostcxxlibs-y) $(hostcxxlibs-m))

########################################
# Filter files                         #
########################################

# C code
# Executables compiled from a single .c file
host-csingle	:= $(foreach m,$(hostprogs), \
			        $(if $($(m)-objs)$($(m)-cxxobjs)$($(m)-sharedobjs),,$(m)))

# C executables linked based on several .o files
host-cmulti	:= $(foreach m,$(hostprogs), \
		       $(if $($(m)-cxxobjs),,$(if $($(m)-objs),$(m))))

# Shared object libraries
host-shared	:= $(foreach m,$(hostprogs),\
		   	   $(if $($(m)-sharedobjs),$(m)))

# Object (.o) files compiled from .c files
host-cobjs	:= $(sort $(foreach m,$(hostprogs),$($(m)-objs)))

# C++ code
# C++ executables compiled from at least one .cc file
# and zero or more .c files
host-cxxmulti	:= $(foreach m,$(hostprogs),$(if $($(m)-cxxobjs),$(m)))

# C++ Object (.o) files compiled from .cc files
host-cxxobjs	:= $(sort $(foreach m,$(host-cxxmulti),$($(m)-cxxobjs)))

# Object (.o) files used by the shared libaries
host-cshobjs	:= $(sort $(foreach m,$(host-cshlib),$($(m:.so=-objs))))
host-cxxshobjs	:= $(sort $(foreach m,$(host-cxxshlib),$($(m:.so=-objs))))

########################################
# Add path                             #
########################################

host-csingle	:= $(addprefix $(obj)/,$(host-csingle))
host-cmulti		:= $(addprefix $(obj)/,$(host-cmulti))
host-shared		:= $(addprefix $(obj)/,$(host-shared))
host-cobjs		:= $(addprefix $(obj)/,$(host-cobjs))
host-cxxmulti	:= $(addprefix $(obj)/,$(host-cxxmulti))
host-cxxobjs	:= $(addprefix $(obj)/,$(host-cxxobjs))
host-cshlib		:= $(addprefix $(obj)/,$(host-cshlib))
host-cxxshlib	:= $(addprefix $(obj)/,$(host-cxxshlib))
host-cshobjs	:= $(addprefix $(obj)/,$(host-cshobjs))
host-cxxshobjs	:= $(addprefix $(obj)/,$(host-cxxshobjs))

########################################
# HOSTCC options                       #
########################################

#
# Build flag
_hostc_flags   = $(KBUILD_HOSTCFLAGS)   $(HOST_EXTRACFLAGS)   \
                 $(HOSTCFLAGS_$(basetarget).o)
_hostcxx_flags = $(KBUILD_HOSTCXXFLAGS) $(HOST_EXTRACXXFLAGS) \
                 $(HOSTCXXFLAGS_$(basetarget).o)

ifeq ($(KBUILD_SRC),)
__hostc_flags	= $(_hostc_flags)
__hostcxx_flags	= $(_hostcxx_flags)
else
__hostc_flags	= -I$(obj) $(call flags,_hostc_flags)
__hostcxx_flags	= -I$(obj) $(call flags,_hostcxx_flags)
endif
#
# Add dependent file				
hostc_flags		= -Wp,-MD,$(depfile) $(__hostc_flags)
hostcxx_flags	= -Wp,-MD,$(depfile) $(__hostcxx_flags)

########################################
# Start build                          #
########################################

# Create executable from a single .c file
# host-csingle -> Executable
quiet_cmd_host-csingle 	= $(ECHO_HOSTCC)  $@
      cmd_host-csingle	= $(HOSTCC) $(hostc_flags) -o $@ $< \
	  	$(KBUILD_HOSTLDLIBS) $(HOSTLDLIBS_$(@F))
$(host-csingle): $(obj)/%: $(src)/%.c FORCE
	$(call if_changed_dep,host-csingle)

# Link an executable based on list of .o files, all plain c
# host-cmulti -> executable
quiet_cmd_host-cmulti	= $(ECHO_HOSTLD)  $@
      cmd_host-cmulti	= $(HOSTCC) $(KBUILD_HOSTLDFLAGS) -o $@ \
			  $(addprefix $(obj)/,$($(@F)-objs)) \
			  $(KBUILD_HOSTLDLIBS) $(HOSTLDLIBS_$(@F))
$(host-cmulti): FORCE
	$(call if_changed,host-cmulti)
$(call multi_depend, $(host-cmulti), , -objs)

# Create .o file from a single .c file
# host-cobjs -> .o
quiet_cmd_host-cobjs	= $(ECHO_HOSTCC) $@
      cmd_host-cobjs	= $(HOSTCC) $(hostc_flags) -c -o $@ $<
$(host-cobjs): $(obj)/%.o: $(src)/%.c FORCE
	$(call if_changed_dep,host-cobjs)

# Link an executable based on list of .o files, a mixture of .c and .cc
# host-cxxmulti -> executable
quiet_cmd_host-cxxmulti	= $(ECHO_HOSTLD) $@
      cmd_host-cxxmulti	= $(HOSTCXX) $(KBUILD_HOSTLDFLAGS) -o $@ \
			  $(foreach o,objs cxxobjs,\
			  $(addprefix $(obj)/,$($(@F)-$(o)))) \
			  $(KBUILD_HOSTLDLIBS) $(HOSTLDLIBS_$(@F))
$(host-cxxmulti): FORCE
	$(call if_changed,host-cxxmulti)

$(call multi_depend, $(host-cxxmulti), , -objs -cxxobjs)

# Create .o file from a single .cc (C++) file
quiet_cmd_host-cxxobjs	= $(ECHO_HOSTCXX) $@
      cmd_host-cxxobjs	= $(HOSTCXX) $(hostcxx_flags) -c -o $@ $<
$(host-cxxobjs): $(obj)/%.o: $(src)/%.cc FORCE
	$(call if_changed_dep,host-cxxobjs)

# Compile .c file, create position independent .o file
# host-cshobjs -> .o
quiet_cmd_host-cshobjs	= $(ECHO_HOSTCC)  -fPIC $@
      cmd_host-cshobjs	= $(HOSTCC) $(hostc_flags) -fPIC -c -o $@ $<
$(host-cshobjs): $(obj)/%.o: $(src)/%.c FORCE
	$(call if_changed_dep,host-cshobjs)

# Compile .c file, create position independent .o file
# Note that plugin capable gcc versions can be either C or C++ based
# therefore plugin source files have to be compilable in both C and C++ mode.
# This is why a C++ compiler is invoked on a .c file.
# host-cxxshobjs -> .o
quiet_cmd_host-cxxshobjs	= $(ECHO_HOSTCXX) -fPIC $@
      cmd_host-cxxshobjs	= $(HOSTCXX) $(hostcxx_flags) -fPIC -c -o $@ $<
$(host-cxxshobjs): $(obj)/%.o: $(src)/%.c FORCE
	$(call if_changed_dep,host-cxxshobjs)

# Link a shared library, based on position independent .o files
# *.o -> .so shared library (host-cshlib)
quiet_cmd_host-cshlib	= $(ECHO_HOSTLLD) -shared $@
      cmd_host-cshlib	= $(HOSTCC) $(HOSTLDFLAGS) -shared -o $@ \
			  $(addprefix $(obj)/,$($(@F:.so=-objs))) \
			  $(HOST_LOADLIBES) $(HOSTLDLIBS_$(@F))
$(host-cshlib): FORCE
	$(call if_changed,host-cshlib)

$(call multi_depend, $(host-cshlib), .so, -objs)

# Link a shared library, based on position independent .o files
# *.o -> .so shared library (host-cxxshlib)
quiet_cmd_host-cxxshlib	= $(ECHO_HOSTLLD) -shared $@
      cmd_host-cxxshlib	= $(HOSTCXX) $(HOSTLDFLAGS) -shared -o $@ \
			  $(addprefix $(obj)/,$($(@F:.so=-objs))) \
			  $(HOST_LOADLIBES) $(HOSTLDLIBS_$(@F))
$(host-cxxshlib): FORCE
	$(call if_changed,host-cxxshlib)
	
$(call multi_depend, $(host-cxxshlib), .so, -objs)

########################################
# All build files                      #
########################################

targets += $(host-csingle)  $(host-cmulti) $(host-cobjs)\
	   $(host-cxxmulti) $(host-cxxobjs) $(host-shared) \
	   $(host-cshlib) $(host-cshobjs) $(host-cxxshlib) $(host-cxxshobjs)
