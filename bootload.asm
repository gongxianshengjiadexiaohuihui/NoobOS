;noob-os
;TAB=4

BOTPAK	EQU 	0x00280000	;引导程序包加载目标
DSKCAC 	EQU 	0x00100000	;磁盘缓存位置
DSKCAC0 EQU 	0x00008000	;磁盘缓存位置（实模式）

;BOOT_INFO(在自由内存区)
CYLS	EQU		0x0ff0			;设定启动区
FLAG	EQU		0x0ff1			;记录键盘标志位,各种功能键的的开关状态比如NUM LOCK、CAPS LOCK等
VMODE	EQU		0x0ff2			;关于颜色数目的信息，颜色的位数
SCRNX	EQU		0x0ff4			;分辨率的x
SCRNY	EQU		0x0ff6			;分辨率的y
VRAM	EQU		0x0ff8			;图像缓冲区的开始地址

		ORG		0xc200			;这个程序要被加载到内存的地址（0xc0000-0xc7fff为显卡bios使用）
		MOV		AL,0x13			;13H	VGA显卡，320*200*8位彩色
		MOV 	AH,0x00	
		INT		0x10
		MOV		BYTE[VMODE],8	;记录画面模式
		MOV		WORD[SCRNX],320 
		MOV		WORD[SCRNY],200
		MOV		DWORD[VRAM],0x000a0000	;VRAM是从0xa0000到0xaffff的64KB(根据内存分布地图)。这里之所以前面加3个0推测是没有3个字节的"数据大小",只有1、2、4个字节

;通过中断获取键盘上标志
		MOV		AH,0x02
		INT		0x16
		MOV		[FLAG],AL
fin:
		HLT
		JMP		fin
;初始化PIC芯片
		MOV		AL,0xff
		OUT		0x21,AL			;0x21是主PIC写入端口，
		NOP						;如果继续执行out，似乎不起作用
		OUT		0xa1,AL			;0x20是从PIC写入端口
		
;打开A20GATE，以便CPU可以访问1MB以上的内存
		IN		AL,0x92	
		OR      AL,0x02  		;将位1变为1 or 00000010b，关闭是and 11111101b
		OUT		0x92,AL
;切换到保护模式
		LGDT	[GDTR0]			;设置临时的GDT，进入保护模式前必须设定GDT。
		MOV		EAX,CR0			;CR0 是 32 位的寄存器，包含了一系列用于控制处理器操作模式和运行状态的标志位
		AND		EAX,0x7fffffff	;设置位31为0(为了禁止分页)
		OR		EAX,0x00000001	;设置位0为1（为了切换到保护模式）
		MOV		CR0,EAX		
		JMP		pipelineflush
;切换到保护模式后，需要初始化段寄存器
;段选择子的结构是
;15-3 		   2		  1-0
;描述符索引    TI		  RPL  
pipelineflush:
		MOV		AX,1*8			;对应段 1#
		MOV		DS,AX
		MOV		ES,AX
		MOV		FS,AX
		MOV		GS,AX
		MOV		SS,AX
		
		ALIGNB	16				;地址对其，能被16整除

;转运bootpack到指定位置
		MOV		ESI,bootpack	;源地址
		MOV		EDI,BOTPAK		;目标地址
		MOV		ECX,512*1024/4	;转送的数据大小512KB(其实没这么大，预留空间)
		CALL 	memcpy			;将引导程序加载到0x00280000这个地址

;转运磁盘的数据
;启动扇区 启动扇区可参考ipl.asm 是加载到0x7c00这个位置
		MOV		ESI,0x7c00		;源地址
		MOV		EDI,DSKCAC		;目标地址
		MOV		ECX,512/4		;数据大小512B
		CALL	memcpy
;所有剩下其它的，参考ipl.asm是加载到0x0820这个位置
		MOV		ESI,DSKCAC0+512		;源地址 
		MOV		EDI,DSKCAC+512	;目标地址
		MOV		ECX,0
		MOV		CL,BYTE[CYLS]	;读出柱面数
		IMUL	ECX,512*18*2/4	
		SUB		ECX,512/4		;要减去启动区的字节数，因为启动区已经加载过了
		CALL 	memcpy
;bootpack启动,下面是编译后文件结构
;0x0000 (DWORD) ……请求操作系统为应用程序准备的数据段的大小
;0x0004 (DWORD) ……“Hari”（.hrb文件的标记）
;0x0008 (DWORD) ……数据段内预备空间的大小
;0x000c (DWORD) ……ESP初始值&数据部分传送目的地址
;0x0010 (DWORD) ……hrb文件内数据部分的大小
;0x0014 (DWORD) ……hrb文件内数据部分从哪里开始
;0x0018 (DWORD) ……0xe9000000
;0x001c (DWORD) ……应用程序运行入口地址 - 0x20
;0x0020 (DWORD) ……malloc空间的起始地址
		MOV 	EBX,BOTPAK
		MOV		ECX,[EBX+16]
		ADD		ECX,3			;这个地方为啥要加3？
		SHR		ECX,2			;除以4，计算memcpy要转运的次数
		JZ		skip
		MOV		ESI,[EBX+20]	;源地址
		ADD		ESI,EBX
		MOV		EDI,[EBX+12]	;目标地址
		CALL	memcpy
skip:
		MOV		ESP,[EBX+12]	;栈初始值
		JMP		DWORD 2*8:0x0000001b;2是段号，因为在0x0018（其实是0x001b）写了一个JMP指令，这样可以通过JMP指令跳转到应用程序的运行入口地址。通过这样的处理，只要先JMP到0x001b这个地址，程序就可以开始运行了。
;内存复制
memcpy:
		MOV		EAX,[ESI]		;把ESI地址的内容复制给EAX
		ADD     ESI,4           ;ESI地址+4
		MOV     [EDI],EAX		;把EAX的内容赋值给EDI内容的内存地址中
		ADD		EDI,4			
		SUB		ECX,1			;ECX里面存放的是需要复制的个数，每个是4个字节，因为寄存器是32位，一次转移4个字节
		JNZ		memcpy			;如果没完成继续复制
		RET


;全局描述符表GDT
GDT0:
		RESB	8				;NULL selector																0#描述符
		DW		0xffff,0x0000,0x9200,0x00cf	;可以读写的段(segment)32bit										1#描述符
		DW  	0xffff,0x0000,0x9a28,0x0047	;可以执行的段(segment)32bit(bootpack用)基地址0x00280000(小端)	2#描述符
		DW		0

;GDTR是存放GDT的寄存器一共48位，保存的是32位的线性地址和16位的边界
GDTR0:
		DW		8*3-1			;边界=表的大小(总字节数)-1
		DD		GDT0			;GDT的地址
		
		ALIGNB	16
bootpack: