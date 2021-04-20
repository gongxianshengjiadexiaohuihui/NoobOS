;haltfunc
;TAB=4

[BITS 32]					;制作32位模式的机器语言
	
		GLOBAL iohlt		;程序中包含的函数名，globl指示告诉汇编器，iohlt这个符号要被链接到,用到这个函数的地方会被替换成这个函数的地址
[SECTION .text]		;.text是代码段 .data是数据段  

;void io_hlt(void);
iohlt:
		HLT
		RET