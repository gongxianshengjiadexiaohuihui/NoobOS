;noob-os
;TAB=4

;BOOT_INFO
CYLS	EQU		0x0ff0			;设定启动区
FLAG	EQU		0x0ff1			;记录键盘标志位,各种功能键的的开关状态比如NUM LOCK、CAPS LOCK等
VMODE	EQU		0x0ff2			;关于颜色数目的信息，颜色的位数
SCRNX	EQU		0x0ff4			;分辨率的x
SCRNY	EQU		0x0ff6			;分辨率的y
VRAM	EQU		0x0ff8			;图像缓冲区的开始地址

		ORG		0xc200			;这个程序要被加载到内存的地址
		MOV		AL,0x13			;13H	VGA显卡，320*200*8位彩色
		MOV 	AH,0x00	
		INT		0x10
		MOV		BYTE[VMODE],8	;记录画面模式
		MOV		WORD[SCRNX],320 
		MOV		WORD[SCRNY],200
		MOV		DWORD[VRAM],0x000a0000	;VRAM是从0xa0000到0xaffff的64KB。这里之所以前面加3个0推测是没有3个字节的"数据大小",只有1、2、4个字节

;通过中断获取键盘上标志
		MOV		AH,0x02
		INT		0x16
		MOV		[FLAG],AL
fin:
		HLT
		JMP		fin