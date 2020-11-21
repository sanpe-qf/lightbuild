# SPDX-License-Identifier: GPL-2.0
# ==========================================================================
# Build define
# ==========================================================================

########################################
# Get include file                     #
########################################

# Use LINUXINCLUDE when you must reference the include/ directory.
# Needed to be compatible with the O= option
INCLUDE    := -Iinclude \
                   -I$(srctree)/include


