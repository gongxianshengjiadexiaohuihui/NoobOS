;haltfunc
;TAB=4

;c语言参数在内存中的位置,返回值是EAX
;第一个参数的存放地址：[ESP + 4]
;第二个参数的存放地址：[ESP + 8]
;第三个参数的存放地址：[ESP + 12]
;第四个参数的存放地址：[ESP + 16],以此类推
[FORMAT "WCOFF"]				; 创建目标文件的模式
[INSTRSET "i486p"]				; 指令集
[FILE "asmfunc.asm"]			; 文件名
[BITS 32]					;制作32位模式的机器语言

;程序中包含的函数名，globl指示告诉汇编器，iohlt这个符号要被链接到,用到这个函数的地方会被替换成这个函数的地址
		GLOBAL _io_hlt,_io_cli,_io_sti,io_stihlt
		GLOBAL _io_in8,_io_in16,io_in32
		GLOBAL _io_out8,io_out16,io_out32
		GLOBAL _io_load_eflags,_io_store_eflags
		
[SECTION .text]		;.text是代码段 .data是数据段  

;void io_hlt(void);执行HLT让CPU进入暂停
_io_hlt:
		HLT
		RET
;void io_cli(void);禁止中断
_io_cli:
		CLI
		RET
;void io_sti(void);恢复中断
_io_sti:
		STI
		RET
;void io_stihlt(void);恢复中断，cpu暂停
_io_stihlt:
		STI	
		HLT
		RET
;int io_in8(int port);从指定端口读出一个字节
_io_in8:
		MOV 	EDX,[ESP+4]			;取出端口号
		MOV 	EAX,0
		IN  	AL,DX
		RET
;int io_in16(int port);从指定端口读出两个字节
_io_in16:
		MOV 	EDX,[ESP+4]			;取出端口号
		MOV	 	EAX,0
		IN  	AX,DX
		RET
;int io_in32(int port);从指定端口读出四个字节
_io_in32:
		MOV 	EDX,[ESP+4]			;取出端口号
		IN  	EAX,DX
		RET
;void io_out8(int port,int data);向指定端口写入1个字节
_io_out8:
		MOV 	EDX,[ESP+4]			;端口号
		MOV 	AL,[ESP+8]			;数据
		OUT		DX,AL
		RET
;void io_out16(int port,int data);向指定端口写入2个字节
_io_out16:
		MOV 	EDX,[ESP+4]			;端口号
		MOV 	EAX,[ESP+8]			;数据
		OUT		DX,AX
		RET
;void io_out32(int port,int data);向指定端口写入4个字节
_io_out32:
		MOV 	EDX,[ESP+4]			;端口号
		MOV 	EAX,[ESP+8]			;数据
		OUT		DX,EAX
		RET
;int io_load_eflags(void);返回标志寄存器的值
_io_load_eflags:
		PUSHFD					;PUSH flags double-word 将标志位的值按双字长压栈
		POP		EAX
		RET
;void io_store_eflags(int eflags);更改标志寄存器的值
_io_store_eflags:
		MOV 	EAX,[ESP]
		PUSH 	EAX
		POPFD					;POP flags double-word 将标志的值按双字长从栈弹出
		RET