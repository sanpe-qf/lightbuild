# SPDX-License-Identifier: GPL-2.0
# ==========================================================================
# Build General
# ==========================================================================

# Shorthand for $(Q)$(MAKE) -f scripts/build_host.mk obj=
# Usage:
# $(Q)$(MAKE) $(build_host)=dir
build_host := -f $(BUILD_HOME)/build_host.mk obj
