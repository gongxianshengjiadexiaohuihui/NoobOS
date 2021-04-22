;haltfunc
;TAB=4

[FORMAT "WCOFF"]				; 创建目标文件的模式
[INSTRSET "i486p"]				; 指令集
[FILE "asmfunc.asm"]			; 文件名
[BITS 32]					;制作32位模式的机器语言

;程序中包含的函数名，globl指示告诉汇编器，iohlt这个符号要被链接到,用到这个函数的地方会被替换成这个函数的地址
		GLOBAL _io_hlt,_write_mem8
[SECTION .text]		;.text是代码段 .data是数据段  

;void io_hlt(void);执行HLT让CPU进入暂停
_io_hlt:
		HLT
		RET
;void write_mem8(int addr,int data) 向内存中写入8位数据
;c语言参数在内存中的位置
;第一个参数的存放地址：[ESP + 4]
;第二个参数的存放地址：[ESP + 8]
;第三个参数的存放地址：[ESP + 12]
;第四个参数的存放地址：[ESP + 16],以此类推
_write_mem8:
		MOV 	ECX,[ESP+4]
		MOV		AL,[ESP+8]
		MOV		[ECX],AL
		RET