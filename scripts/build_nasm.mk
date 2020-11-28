# SPDX-License-Identifier: GPL-2.0
# ==========================================================================
# Build nasm
# ==========================================================================

ifdef ARCH
ifneq ($(ARCH),x86)
$(warning NASM only works with x86 architecture)
endif
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
nasm-multi	:= $(foreach m,$(nasm),$(if $($(m)-objs),$(m)))

# Object (.o) files compiled from .S files
nasm-objs	:= $(sort $(foreach m,$(nasm),$($(m)-objs)))

########################################
# Add path                             #
########################################

nasm-single	:= $(addprefix $(obj)/,$(nasm-single))

########################################
# NASM options                         #
########################################

nasm_flags += -I $(src) $(INCLUDE)

########################################
# Start build                          #
########################################

# Create executable from a single .S file
# nasm-single -> Executable
quiet_cmd_nasm-single 	= $(ECHO_NASM)  $@
      cmd_nasm-single	= $(NASM) $(nasm_flags) -o $@ $< 
$(nasm-single): $(obj)/%: $(src)/%.S FORCE
	$(call if_changed,nasm-single)

quiet_cmd_nasm-multi 	= $(ECHO_NASM)  $@
      cmd_nasm-multi	= $(NASM) $(nasm_flags) -o $@ $< 
$(nasm-multi): $(obj)/%: $(src)/%.S FORCE
	$(call if_changed,nasm-multi)

targets += $(nasm-single)