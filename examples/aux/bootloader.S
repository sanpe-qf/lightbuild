.text
.global _start

_start:
	/* 关看门狗 */
	LDR   R0,=0x01C20CB4 /*datasheet手册搜索WDOG0_CFG*/
	MOV   R1,#0x0		      
	STR   R1,[R0]		      
	/* 为使用C语言设置堆栈 */
	LDR   SP,=65536   	  
	/* 跳转到main */
	BL	main

halt:
	B   halt
		
	






















