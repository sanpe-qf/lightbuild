cust-always-y += start
start-obj-y += start.o setup.o lib.o page.o

cust-as := nasm
cust-asflags-y := -f elf -I $(obj)
cust-ccflags-y := -fno-builtin -Wall -Wunused -fno-PIE -m32 -fno-stack-protector
cust-ldflags-y := -m elf_i386 -no-pie -e _start -Ttext 0x91000
