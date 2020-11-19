# SPDX-License-Identifier: GPL-2.0
# ==========================================================================
# Recursion build system
# ==========================================================================
submk := $(obj)

_build:

#
# Read auto.conf if it exists, otherwise ignore
-include $(MAKE_HOME)/config/auto.conf

#
# Include Buildsystem function
include $(BUILD_HOME)/define.mk

#
# Include sub makefile
sub-dir := $(if $(filter /%,$(submk)),$(submk),$(MAKE_HOME)/$(submk))
sub-file := $(if $(wildcard $(sub-dir)/Kbuild),$(sub-dir)/Kbuild,$(sub-dir)/Makefile)
include $(sub-file)

########################################
# Start project                        #
########################################

project		:= $(project-y)
project		:= $(sort $(project))
project		:= $(filter %/, $(project))
project		:= $(subst /,, $(project))
project		:= $(addprefix $(obj)/,$(project))

########################################
# Start build                          #
########################################

PHONY += _build
_build: $(project)
	$(Q)$(MAKE) $(build)=$(sub-dir)

########################################
# Start clean                          #
########################################

#
# clean
PHONY += $(clean-dirs) clean 

RCS_FIND_IGNORE := \( -name SCCS -o -name BitKeeper -o \
                      -name .svn -o -name CVS -o -name .pc -o \
					  -name .hg -o -name .git \) -prune -o

_clean: $(project) 
	$(Q)$(MAKE) $(clean)=$(sub-dir)
		
#
# mrproper
PHONY += distclean

MRPROPER_DIRS  += include/config include/generated
MRPROPER_FILES += .config .config.old tags TAGS cscope* GPATH GTAGS GRTAGS GSYMS

mrproper: rm-dirs  := $(wildcard $(MRPROPER_DIRS))
mrproper: rm-files := $(wildcard $(MRPROPER_FILES))
mrproper-dirs      := $(addprefix _mrproper_, scripts)

PHONY += $(mrproper-dirs) mrproper
$(mrproper-dirs):
	$(Q)$(MAKE) $(clean)=$(patsubst _mrproper_%,%,$@)

_mrproper: $(project) clean $(mrproper-dirs)
	$(call cmd,rmdirs)
	$(call cmd,rmfiles)

# distclean
#
PHONY += distclean

_distclean: $(project) mrproper
	$(Q)find $(srctree) $(RCS_FIND_IGNORE) \
		\( -name '*.orig' -o -name '*.rej' -o -name '*~' \
		-o -name '*.bak' -o -name '#*#' -o -name '.*.orig' \
		-o -name '.*.rej' -o -size 0 \
		-o -name '*%' -o -name '.*.cmd' -o -name 'core' \) \
		-type f -print | xargs rm -f

########################################
# Self operation                       #
########################################

build-dirs	:= $(addprefix _build_, $(project))
$(build-dirs):
	echo $(patsubst _build_%,%,$@)
	# $(Q)$(MAKE) $(remake)=$(patsubst _build_%,%,$@)

########################################
# Descending operation                 #
########################################

PHONY += $(project)
$(project):
	$(Q)$(MAKE) $(remake)=$@ $(MAKECMDGOALS)

########################################
# Start FORCE                          #
########################################

PHONY += FORCE 
FORCE:

# Declare the contents of the PHONY variable as phony.  We keep that
# information in a variable so we can use it in if_changed and friends.
.PHONY: $(PHONY)
