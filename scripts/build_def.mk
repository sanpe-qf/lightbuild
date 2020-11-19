# SPDX-License-Identifier: GPL-2.0
# ==========================================================================
# Build define
# ==========================================================================

########################################
# Get include file                     #
########################################

# Use LINUXINCLUDE when you must reference the include/ directory.
# Needed to be compatible with the O= option
INCLUDE    := -Iinclude \
                   -I$(srctree)/include


########################################
# Project build flag                   #
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