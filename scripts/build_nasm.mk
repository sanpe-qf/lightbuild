# SPDX-License-Identifier: GPL-2.0
# ==========================================================================
# Build nasm
# ==========================================================================

ifneq ($(ARCH),x86)
$(warning NASM only works with x86 architecture)
endif

########################################
# Sort files                           #
########################################

nasm := $(sort $(nasm))

########################################
# Filter files                         #
########################################

# nasm code
# Executables compiled from a single .S file
nasm-single	:= $(foreach m,$(nasm), \
			$(if $($(m)-objs),,$(m)))

# C executables linked based on several .o files
nasm-multi	:= $(foreach m,$(nasm), \
		    $(if $($(m)-cxxobjs),,$(if $($(m)-objs),$(m))))

# Object (.o) files compiled from .S files
nasm-objs	:= $(sort $(foreach m,$(nasm),$($(m)-objs)))

########################################
# Add path                             #
########################################

nasm-single	:= $(addprefix $(obj)/,$(nasm-single))

########################################
# NASM options                         #
########################################

ifeq ($(nasm_flags),)
nasm_flags := -I $(src)
endif

########################################
# Start build                          #
########################################

# Create executable from a single .c file
# host-csingle -> Executable
quiet_cmd_nasm-single 	= $(ECHO_NASM)  $@
      cmd_nasm-single	= $(NASM) $(nasm_flags) -o $@ $< 
$(nasm-single): $(obj)/%: $(src)/%.S FORCE
	$(call if_changed,nasm-single)

targets += $(nasm-single)