deps_config := \
	examples/Kconfig \
	/disk/d/code/product/light-build/Kconfig

include/config/auto.conf: \
	$(deps_config)


$(deps_config): ;
