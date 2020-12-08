# SPDX-License-Identifier: GPL-2.0
# ==========================================================================
# Always build 
# ==========================================================================


result 	+= $(obj-y)

result 	+= $(elf-always-y)
result 	+= $(lib-always-y)
result 	+= $(bin-always-y)
result 	+= $(nasm-always-y)
result 	+= $(cust-always-y)
result 	+= $(hostprogs-always-y)
result	+= $(host-csingle)  $(host-cmulti) $(host-cobjs)\
	   $(host-cxxmulti) $(host-cxxobjs) $(host-shared) \
	   $(host-cshlib) $(host-cshobjs) $(host-cxxshlib) $(host-cxxshobjs)
result 	+= $(always-y)


