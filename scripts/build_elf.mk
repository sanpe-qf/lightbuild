

########################################
# Sort file                            #
########################################

elf			:= $(sort $(elf))
elf			:= $(addprefix $(obj)/,$(elf))

$(elf):
	echo "hello"