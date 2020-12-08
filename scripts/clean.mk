# SPDX-License-Identifier: GPL-2.0
# ==========================================================================
# Cleaning up
# ==========================================================================

_clean:
src := $(obj)

#
# Include Buildsystem function
include $(BUILD_HOME)/include/define.mk

# The filename Kbuild has precedence over Makefile
clean-dir := $(if $(filter /%,$(src)),$(src),$(MAKE_HOME)/$(src))
clean-file := $(if $(wildcard $(clean-dir)/Kbuild),$(clean-dir)/Kbuild,$(clean-dir)/Makefile)
include $(clean-file)

#
# Include Buildsystem function

include $(BUILD_HOME)/main/main_rule.mk
include $(BUILD_HOME)/modules/cust_rule.mk
include $(BUILD_HOME)/modules/host_rule.mk
include $(BUILD_HOME)/modules/name_rule.mk
include $(BUILD_HOME)/modules/nasm_rule.mk

########################################
# Filter sub dir                       #
########################################

#
# filter sub ymn
subdir-y	:= $(patsubst %/,%,$(filter %/, $(obj-y)))
subdir-		:= $(patsubst %/,%,$(filter %/, $(obj-)))
# Subdirectories we need to descend into
subdir-real	:= $(sort $(subdir-y) $(subdir-m) $(subdir-))
# Add path
subdir-real	:= $(addprefix $(obj)/,$(subdir-ymn))

########################################
# Filter files                         #
########################################

clean-y		:= $(addprefix $(obj)/,$(clean-y))
clean-y		:= $(wildcard $(clean-y))

clean-files	:= $(wildcard $(clean-files))
clean-cmd 	:= $(wildcard $(foreach f,$(clean-y) $(clean-files),$(dir $(f)).$(notdir $(f)).cmd))

# build a list of files to remove, usually relative to the current
# directory
clean_files	+= $(clean-y) $(clean-files) $(clean-cmd)

# clean-files	:= $(filter-out %/, $(clean-files))

# clean-files is given relative to the current directory, unless it
# starts with $(objtree)/ (which means "./", so do not add "./" unless
# you want to delete a file from the toplevel object directory).
# clean-files   := $(wildcard                                               \
# 		   $(addprefix $(obj)/, $(filter-out $(objtree)/%, $(clean-files))) \
# 		   $(filter $(objtree)/%, $(clean-files)))

# same as clean-files
clean-dirs    := $(wildcard                                               \
		   $(addprefix $(obj)/, $(filter-out $(objtree)/%, $(clean-dirs)))    \
		   $(filter $(objtree)/%, $(clean-dirs)))

########################################
# Start rule                           #
########################################

quiet_cmd_clean_file   	= $(ECHO_CLEAN)	$@
      cmd_clean_file	= rm -f $@
$(clean_files): FORCE
	$(call cmd,clean_file)

quiet_cmd_clean_dir 	= $(ECHO_CLEAN_DIR) $@
      cmd_clean_dir 	= rm -rf $(clean-dirs)
$(clean-dirs): FORCE
	$(call cmd,clean_dir)

########################################
# Start clean                          #
########################################

PHONY += _clean
_clean: $(clean_files) $(clean_dirs) $(subdir_real)

########################################
# Descending clean                     #
########################################
PHONY += $(subdir-ymn)
$(subdir-ymn):
	$(Q)$(MAKE) $(clean)=$@

PHONY += FORCE 
FORCE:

# Declare the contents of the PHONY variable as phony.  We keep that
# information in a variable so we can use it in if_changed and friends.
.PHONY: $(PHONY)
