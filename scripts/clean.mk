# SPDX-License-Identifier: GPL-2.0
# ==========================================================================
# Cleaning up
# ==========================================================================

_clean:
src := $(obj)

#
# Include Buildsystem function
include $(BUILD_HOME)/define.mk

# The filename Kbuild has precedence over Makefile
clean-dir := $(if $(filter /%,$(src)),$(src),$(MAKE_HOME)/$(src))
clean-file := $(if $(wildcard $(clean-dir)/Kbuild),$(clean-dir)/Kbuild,$(clean-dir)/Makefile)
include $(clean-file)

########################################
# Filter sub dir                       #
########################################

#
# filter sub ymn
subdir-y	:= $(patsubst %/,%,$(filter %/, $(obj-y)))
subdir-m	:= $(patsubst %/,%,$(filter %/, $(obj-m)))
subdir-		:= $(patsubst %/,%,$(filter %/, $(obj-)))
# Subdirectories we need to descend into
subdir-ymn      := $(sort $(subdir-y) $(subdir-m) $(subdir-))
# Add path
subdir-ymn		:= $(addprefix $(obj)/,$(subdir-ymn))

########################################
# Filter files                         #
########################################

# build a list of files to remove, usually relative to the current
# directory
clean-files	:= $(obj-y) $(extra-y) $(extra-m) $(extra-)	\
		   $(always) $(targets) $(clean-files)		\
		   $(hostprogs-y) $(hostprogs-m) $(hostprogs) 	\
		   $(hostlibs-y) $(hostlibs-m) $(hostlibs-) 	\
		   $(hostcxxlibs-y) $(hostcxxlibs-m)

clean-files	:= $(filter-out %/, $(clean-files))

# clean-files is given relative to the current directory, unless it
# starts with $(objtree)/ (which means "./", so do not add "./" unless
# you want to delete a file from the toplevel object directory).
clean-files   := $(wildcard                                               \
		   $(addprefix $(obj)/, $(filter-out $(objtree)/%, $(clean-files))) \
		   $(filter $(objtree)/%, $(clean-files)))

# same as clean-files
clean-dirs    := $(wildcard                                               \
		   $(addprefix $(obj)/, $(filter-out $(objtree)/%, $(clean-dirs)))    \
		   $(filter $(objtree)/%, $(clean-dirs)))

########################################
# Start clean                          #
########################################

quiet_cmd_clean    = $(ECHO_CLEAN)   $(obj)
      cmd_clean    = rm -f $(clean-files)
quiet_cmd_cleandir = $(ECHO_CLEAN)   $(clean-dirs)
      cmd_cleandir = rm -rf $(clean-dirs)

PHONY += _clean
_clean: $(subdir-ymn)
ifneq ($(strip $(clean-files)),)
	+$(call cmd,clean)
endif
ifneq ($(strip $(clean-dirs)),)
	+$(call cmd,cleandir)
endif
ifneq ($(strip $(clean-rule)),)
	+$(clean-rule)
endif
	@:

########################################
# Descending clean                     #
########################################
PHONY += $(subdir-ymn)
$(subdir-ymn):
	$(Q)$(MAKE) $(clean)=$@

# Declare the contents of the PHONY variable as phony.  We keep that
# information in a variable so we can use it in if_changed and friends.
.PHONY: $(PHONY)
