# SPDX-License-Identifier: GPL-2.0
# ==========================================================================
# cust rule
# ==========================================================================


########################################
# Always build                         #
########################################

# bin-always-y += foo
# ... is a shorthand for
# bin += foo
# always-y  += foo
bin 		+= $(bin-always-y)
always-y 	+= $(bin-always-y)

# cust-always-y += foo
# ... is a shorthand for
# cust += foo
# always-y  += foo
cust 		+= $(cust-always-y)
always-y 	+= $(cust-always-y)

########################################
# Sort files                           #
########################################

cust := $(sort $(cust))

########################################
# Filter files                         #
########################################

cust-single := $(foreach m,$(cust), \
			$(if $($(m)-obj-y),,$(m)))
			
cust-multi := $(foreach m,$(cust), \
			$(if $($(m)-obj-y),$(m)))

cust-objs	:= $(sort $(foreach m,$(cust),$($(m)-obj-y)))

########################################
# Add path                             #
########################################

cust-single := $(addprefix $(obj)/,$(cust-single))
cust-multi	:= $(addprefix $(obj)/,$(cust-multi))
cust-objs	:= $(addprefix $(obj)/,$(cust-objs))
always-y	:= $(addprefix $(obj)/,$(always-y))

targets += $(cust-objs) $(cust-single) $(cust-multi)
 
########################################
# clean rule                           #
########################################

clean-files += $(cust-single)
clean-files += $(cust-multi)
clean-files += $(cust-objs)
