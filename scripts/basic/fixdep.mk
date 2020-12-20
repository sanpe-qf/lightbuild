# SPDX-License-Identifier: GPL-2.0
# ==========================================================================
# fixdep system
# ==========================================================================

# Basic helpers built in scripts/
PHONY += scripts_basic
scripts_basic:
	$(Q)$(MAKE) $(build)=$(BUILD_HOME)/basic 
