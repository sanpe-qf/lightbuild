# SPDX-License-Identifier: GPL-2.0
# ==========================================================================
# Build define
# ==========================================================================

# Init all relevant variables used in kbuild files so
# 1) they have correct type
# 2) they do not inherit any value from the environment
obj-y :=
obj-m :=
lib-y :=
lib-m :=
always :=
always-y :=
always-m :=
targets :=
subdir-y :=
subdir-m :=
EXTRA_AFLAGS   :=
EXTRA_CFLAGS   :=
EXTRA_CPPFLAGS :=
EXTRA_LDFLAGS  :=
asflags-y  :=
ccflags-y  :=
cppflags-y :=
ldflags-y  :=

subdir-asflags-y :=
subdir-ccflags-y :=


# flags that take effect in current and sub directories
KBUILD_AFLAGS += $(subdir-asflags-y)
KBUILD_CFLAGS += $(subdir-ccflags-y)
