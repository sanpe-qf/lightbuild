# SPDX-License-Identifier: GPL-2.0
# ==========================================================================
# Build cust
# ==========================================================================

########################################
# Sort files                           #
########################################

cust := $(sort $(cust))

########################################
# Filter files                         #
########################################

# S code
# Assemble source files
cust-ass := $(foreach m,$(cust), \
			$(if $($(m)-src)$($(m)-cxxobjs)$($(m)-sharedobjs),,$(m)))

# C code
# Executables compiled from a single .c file
cust-csingle	:= $(foreach m,$(cust), \
			        $(if $($(m)-src)$($(m)-cxxobjs)$($(m)-sharedobjs),,$(m)))

# C executables linked based on several .o files
cust-cmulti	:= $(foreach m,$(cust), \
		       $(if $($(m)-cxxobjs),,$(if $($(m)-objs),$(m))))

# Shared object libraries
cust-shared	:= $(foreach m,$(cust),\
		   	   $(if $($(m)-sharedobjs),$(m)))

# Object (.o) files compiled from .c files
cust-cobjs	:= $(sort $(foreach m,$(cust),$($(m)-objs)))

# C++ code
# C++ executables compiled from at least one .cc file
# and zero or more .c files
cust-cxxmulti	:= $(foreach m,$(cust),$(if $($(m)-cxxobjs),$(m)))

# C++ Object (.o) files compiled from .cc files
cust-cxxobjs	:= $(sort $(foreach m,$(cust-cxxmulti),$($(m)-cxxobjs)))

# Object (.o) files used by the shared libaries
cust-cshobjs	:= $(sort $(foreach m,$(cust-cshlib),$($(m:.so=-objs))))
cust-cxxshobjs	:= $(sort $(foreach m,$(cust-cxxshlib),$($(m:.so=-objs))))










