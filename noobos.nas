;noob-os
;TAB=4
	ORG		0xc200		;这个程序要被加载到内存的地址
	MOV		AL,0x13		;13H   640×480256色
	MOV 	AH,0x00	
	INT		0x10
fin:
    HLT
    JMPfin