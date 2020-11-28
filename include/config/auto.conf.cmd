deps_config := \
	/run/media/sanpe/file/light-build/Kconfig

include/config/auto.conf: \
	$(deps_config)


$(deps_config): ;
