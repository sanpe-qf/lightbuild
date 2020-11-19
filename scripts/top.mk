# SPDX-License-Identifier: GPL-2.0
# ==========================================================================
# System top
# ==========================================================================

########################################
# System start                         #
########################################

all: build

########################################
# Start path                           #
########################################

#
# Project home
MAKE_HOME 	:= $(CURDIR)

#
# Build system home
BUILD_HOME 	:= $(abspath $(lastword $(MAKEFILE_LIST)/../))

#
# Build relative path
objtree		:= .

#
# Kconfig path config
ifdef KBUILD_KCONFIG
Kconfig := $(KBUILD_KCONFIG)
else
KBUILD_KCONFIG := $(MAKE_HOME)/Kconfig
endif

export MAKE_HOME BUILD_HOME objtree KBUILD_KCONFIG

########################################
# Start env                            #
########################################

LIGHYBUILD_VERSION := v1.0

# Do not use make's built-in rules and variables
# Do not print "Entering directory ...",
MAKEFLAGS	+= -rR
MAKEFLAGS	+= --no-print-directory

# To put more focus on warnings, be less verbose as default
# Use 'make V=1' to see the full commands

ifndef V
  DEBUG_MODE := 0
endif

ifeq ("$(origin V)", "command line")
  DEBUG_MODE = $(V)
endif

ifeq ($(DEBUG_MODE),0)
  quiet		=quiet_
  MAKEFLAGS	+= -s
  Q 		= @
endif
ifeq ($(DEBUG_MODE),1)
  quiet =
  Q =
endif
export quiet Q

# OK, Make called in directory where kernel src resides
# Do we want to locate output files in a separate directory?
ifeq ("$(origin O)", "command line")
  KBUILD_OUTPUT := $(O)
endif

ifeq ("$(origin W)", "command line")
  export BUILD_ENABLE_EXTRA_GCC_CHECKS := $(W)
endif

#
# Extre Warning
include $(BUILD_HOME)/build_warn.mk

#
# Read auto.conf if it exists, otherwise ignore
sinclude $(MAKE_HOME)/include/config/auto.conf

#
# Tool Define  
include $(BUILD_HOME)/define.mk

########################################
# Start project                        #
########################################

ifndef project-y
project		:= $(MAKE_HOME)
else
project		:= $(project-y)
project		:= $(sort $(project))
project		:= $(filter %/, $(project))
project		:= $(subst /,, $(project))
project		:= $(addprefix $(MAKE_HOME)/,$(project))
endif

########################################
# Start scripts                        #
########################################

# Basic helpers built in scripts/
PHONY += scripts_basic
scripts_basic:
	$(Q)$(MAKE) $(build)=$(BUILD_HOME)/basic

# outputmakefile generates a Makefile in the output directory, if using a
# separate output directory. This allows convenient use of make in the
# output directory.
PHONY += outputmakefile
outputmakefile:
	$(Q)ln -fsn $(MAKE_HOME) source
	$(Q)$(SHELL) $(MAKE_HOME)/scripts/mkmakefile \
	    $(MAKE_HOME) $(MAKE_HOME) $(VERSION) $(PATCHLEVEL)

########################################
# Start config                         #
########################################

# *config targets only - make sure prerequisites are updated, and descend
# in scripts/kconfig to make the *config target

config_dir := include/config configs
config_dir := $(addprefix $(MAKE_HOME)/,$(config_dir))

config: scripts_basic FORCE
	$(Q)$(MKDIR) $(config_dir)
	$(Q)$(MAKE) $(build)=$(BUILD_HOME)/kconfig $@

menuconfig:
	$(Q)$(MKDIR) $(config_dir)
	$(Q)$(MAKE) $(build)=$(BUILD_HOME)/newconfig $@

%config: scripts_basic FORCE
	$(Q)$(MKDIR) $(config_dir)
	$(Q)$(MAKE) $(build)=$(BUILD_HOME)/kconfig $@

########################################
# Start checkstack                     #
########################################

CHECKSTACK_ARCH := $(ARCH)
CHECKSTACK_EXE  := 

checkstack:
	$(OBJDUMP) -d $(CHECKSTACK_EXE) | $(PERL) \
	$(BUILD_HOME)/checkstack.pl $(CHECKSTACK_ARCH)

########################################
# Start coccicheck                     #
########################################

coccicheck:
	$(Q)$(SHELL) $(BUILD_HOME)/$@

########################################
# Start version                        #
########################################

version:
	$(Q)$(ECHO) $(LIGHYBUILD_VERSION)

########################################
# Start help                           #
########################################

PHONY += help
help:
	$(Q)$(ECHO)  'System version:'
	$(Q)$(ECHO)  '  Build-Version  = $(LIGHYBUILD_VERSION)'
	$(Q)$(ECHO)  '  CC             = $(CC)             '
	$(Q)$(ECHO)  '  CC-Version     = $(call cc-version)'
	$(Q)$(ECHO)  ''
	$(Q)$(ECHO)  'Build targets:'
	$(Q)$(ECHO)  '  build		 - Build all necessary images depending on configuration'
	$(Q)$(ECHO)  ''
	$(Q)$(ECHO)  'Old Configuration targets:'
	$(Q)$(MAKE)   -f $(MAKE_HOME)/scripts/kconfig/Makefile help
	$(Q)$(ECHO)  ''
	$(Q)$(ECHO)  'Configuration targets:'
	$(Q)$(MAKE)   -f $(MAKE_HOME)/scripts/newconfig/Makefile help
	$(Q)$(ECHO)  ''
	$(Q)$(ECHO)  'Other generic targets:'
	$(Q)$(ECHO)  '  info		  - Build targets informatio'
	$(Q)$(ECHO)  ''
	$(Q)$(ECHO)  'Cleaning project:'
	$(Q)$(ECHO)  '  clean		  - Remove most generated files but keep the config'
	$(Q)$(ECHO)  '  mrproper	  - Remove all generated files + config + various backup files'
	$(Q)$(ECHO)  '  distclean	  - mrproper + remove editor backup and patch files'
	$(Q)$(ECHO)  ''
	$(Q)$(ECHO)  'Static analysers'
	$(Q)$(ECHO)  '  checkstack      - Generate a list of stack hogs'
	$(Q)$(ECHO)  '  coccicheck      - Execute static code analysis with Coccinelle'
	$(Q)$(ECHO)  ''
	$(Q)$(ECHO)  '  make V=0|1 [targets] 0 => quiet build (default), 1 => verbose build'
	$(Q)$(ECHO)  '  make V=2   [targets] 2 => give reason for rebuild of target'
	$(Q)$(ECHO)  '  make O=dir [targets] Locate all output files in "dir", including .config'
	$(Q)$(ECHO)  '  make C=1   [targets] Check all c source with $$CHECK (sparse by default)'
	$(Q)$(ECHO)  '  make C=2   [targets] Force check of all c source with $$CHECK'
	$(Q)$(ECHO)  '  make RECORDMCOUNT_WARN=1 [targets] Warn about ignored mcount sections'
	$(Q)$(ECHO)  '  make W=n   [targets] Enable extra gcc checks, n=1,2,3 where'
	$(Q)$(ECHO)  '		1: warnings which may be relevant and do not occur too often'
	$(Q)$(ECHO)  '		2: warnings which occur quite often but may still be relevant'
	$(Q)$(ECHO)  '		3: more obscure warnings, can most likely be ignored'
	$(Q)$(ECHO)  '		Multiple levels can be combined with W=12 or W=123'

########################################
# Start remake                         #
########################################

remake_fun += build clean

PHONY += $(remake_fun) remake

$(remake_fun): remake
remake:FORCE
	$(Q)$(MAKE) $(remake)=$(MAKE_HOME) $(if $(MAKECMDGOALS),_$(MAKECMDGOALS))

########################################
# Start FORCE                          #
########################################

PHONY += FORCE
FORCE:

# Declare the contents of the PHONY variable as phony.  We keep that
# information in a variable so we can use it in if_changed and friends.
.PHONY: $(PHONY)
