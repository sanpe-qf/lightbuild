CROSS_COMPILE := arm-linux-gnueabihf-

always-y += $(bin) $(dump)

bin += led.bin
led.bin-obj-y += $(cust)

dump += led.dis
led.dis-obj-y += $(cust)

cust += led
led-obj-y += bootloader.o main.o
cust-ldflags-y += -T$(obj)/led.lds
