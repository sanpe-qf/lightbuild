# SPDX-License-Identifier: GPL-2.0
# ==========================================================================
# main rule
# ==========================================================================

subdir-y		:= $(obj-y) $(subdir-y)
subdir-y		:= $(strip $(sort $(subdir-y)))
subdir-y		:= $(filter %/, $(subdir-y))
subdir-y		:= $(patsubst %/,%,$(subdir-y))

obj-file	:= $(filter-out %/, $(obj-y))

obj-subfile	:= $(filter %/, $(obj-y))
obj-subfile	:= $(patsubst %/, %/built-in.o, $(obj-subfile))

#
# Sort file
# obj-file-y		:= $(sort $(obj-file-y))
# extra-y			:= $(sort $(extra-y))
# lib-y			:= $(sort $(lib-y))

# obj-file-y		:= $(patsubst %/, %/built-in.o, $(obj-file-y))


# extra-y			:= $(addprefix $(obj)/,$(extra-y))
# lib-y			:= $(addprefix $(obj)/,$(lib-y))

# # Libraries are always collected in one lib file.
# # Filter out objects already built-in

# lib-y := $(filter-out $(obj-y), $(sort $(lib-y)))

# # Subdirectories we need to descend into

# # $(subdir-obj-y) is the list of objects in $(obj-y) which uses dir/ to
# # tell kbuild to descend
# subdir-obj-y := $(filter %/built-in.o, $(obj-y))

# # $(obj-dirs) is a list of directories that contain object files
# obj-dirs := $(dir $(subdir-obj-y))

# # Replace multi-part objects by their individual parts, look at local dir only
# real-objs-y := $(foreach m, $(filter-out $(subdir-obj-y), $(obj-y)), $(if $(strip $($(m:.o=-objs)) $($(m:.o=-y))),$($(m:.o=-objs)) $($(m:.o=-y)),$(m))) $(extra-y)

ifneq ($(strip $(obj-y) $(obj-) $(subdir-m) $(lib-target)),)
builtin-target := $(obj)/built-in.o
endif

########################################
# Add path                             #
########################################

subdir-y		:= $(addprefix $(obj)/,$(subdir-y))
obj-file		:= $(addprefix $(obj)/,$(obj-file))
obj-subfile		:= $(addprefix $(obj)/,$(obj-subfile))

########################################
# targets rule                         #
########################################

main-targets	+= $(obj-file)
main-targets	+= $(builtin-target)
main-targets 	+= $(lib-target)
targets			+= $(main-targets)

########################################
# Always rule                          #
########################################

always-y	+= $(builtin-target)

########################################
# clean rule                           #
########################################

clean-files += $(main-targets)
