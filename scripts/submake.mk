# SPDX-License-Identifier: GPL-2.0
# ==========================================================================
# Recursion build system
# ==========================================================================
submk := $(obj)

_build:

#
# Include Buildsystem function
include $(BUILD_HOME)/include/define.mk

#
# Read auto.conf if it exists, otherwise ignore
-include $(MAKE_HOME)/include/config/auto.conf

#
# Include sub makefile
sub-dir := $(if $(filter /%,$(submk)),$(submk),$(MAKE_HOME)/$(submk))
sub-file := $(if $(wildcard $(sub-dir)/Kbuild),$(sub-dir)/Kbuild,$(sub-dir)/Makefile)
include $(sub-file)

########################################
# Start project                        #
########################################

project		:= $(project-y)
project		:= $(strip $(sort $(project)))
project		:= $(filter %/, $(project))
project		:= $(patsubst %/,%,$(project))
project		:= $(addprefix $(obj)/,$(project))

project-n	:= $(project-)
project-n	:= $(strip $(sort $(project-n)))
project-n	:= $(filter %/, $(project-n))
project-n	:= $(patsubst %/,%,$(project-n))
project-n	:= $(addprefix $(obj)/,$(project-n))

########################################
# include dirs                         #
########################################

INCLUDE		:= $(addprefix $(obj)/,$(project-include-y)) \
				$(project-include-fix) $(INCLUDE)
export INCLUDE

########################################
# Start build                          #
########################################

PHONY += _build
_build: $(project)
	$(Q)$(MAKE) $(basic)
	$(Q)$(MAKE) $(build)=$(sub-dir)
	$(call hook_build)

########################################
# Start remake                         #
########################################

PHONY += _remake
_remake: 
	$(Q)$(MAKE) $(submake)=$(MAKE_HOME) _clean
	$(Q)$(MAKE) $(submake)=$(MAKE_HOME) _build

########################################
# Start build                          #
########################################

PHONY += _env
_env: $(project)
	$(Q)$(MAKE) $(env)=$(sub-dir)

########################################
# Start clean                          #
########################################

#
# clean
PHONY += $(clean-dirs) clean 

RCS_FIND_IGNORE := \( -name SCCS -o -name BitKeeper -o \
                      -name .svn -o -name CVS -o -name .pc -o \
                      -name .hg -o -name .git \) -prune -o

_clean: $(project) $(project-n)
	$(Q)$(MAKE) $(clean)=$(sub-dir)
	$(call hook_clean)

#
# mrproper
MRPROPER_DIRS	+= include/config include/generated
MRPROPER_FILES	+= .config .config.old tags TAGS cscope* GPATH GTAGS GRTAGS GSYMS

MRPROPER_DIRS	:= $(addprefix $(obj)/,$(MRPROPER_DIRS))
MRPROPER_FILES	:= $(addprefix $(obj)/,$(MRPROPER_FILES))

_mrproper: rm-dirs  := $(wildcard $(MRPROPER_DIRS))
_mrproper: rm-files := $(wildcard $(MRPROPER_FILES))
_mrproper: mrproper-dirs := $(addprefix _mrproper_,$(rm-dirs) $(rm-files))

PHONY += _mrproper $(mrproper-dirs)
$(mrproper-dirs):
	echo "fuck you"
	# $(ECHO) $(ECHO_RM)	" eweae$(patsubst _mrproper_%,%,$@)"
	# $(Q)$(MAKE) $(RM) $(patsubst _mrproper_%,%,$@)

_mrproper: $(mrproper-dirs)
	echo "rm-dirs  $(mrproper-dirs)"
	# $(Q)$(MAKE) $(submake)=$(MAKE_HOME) _clean
	$(call cmd,rmdirs)
	$(call cmd,rmfiles)

# distclean
#
PHONY += _distclean

_distclean: $(project) _mrproper
	$(Q)find $(srctree) $(RCS_FIND_IGNORE) \
		\( -name '*.orig' -o -name '*.rej' -o -name '*~' \
		-o -name '*.bak' -o -name '#*#' -o -name '.*.orig' \
		-o -name '.*.rej' -o -size 0 \
		-o -name '*%' -o -name '.*.cmd' -o -name 'core' \) \
		-type f -print | xargs rm -f

########################################
# Start checkstack                     #
########################################

CHECKSTACK_ARCH := $(ARCH)
CHECKSTACK_EXE  := 

_checkstack:
	$(OBJDUMP) -d $(CHECKSTACK_EXE) | $(PERL) \
	$(BUILD_HOME)/checkstack.pl $(CHECKSTACK_ARCH)

########################################
# Start coccicheck                     #
########################################

_coccicheck:
	$(Q)$(SHELL) $(BUILD_HOME)/$@

########################################
# Descending operation                 #
########################################

PHONY += $(project)
$(project): FORCE
	$(Q)$(MAKE) $(submake)=$@ $(MAKECMDGOALS)

PHONY += $(project-n)
$(project-n): FORCE
	$(Q)$(MAKE) $(submake)=$@ $(MAKECMDGOALS)

########################################
# Start FORCE                          #
########################################

PHONY += FORCE 
FORCE:

# Declare the contents of the PHONY variable as phony.  We keep that
# information in a variable so we can use it in if_changed and friends.
.PHONY: $(PHONY)
