; noob-os
; TAB=4

; 标准FAT12格式软盘专用的代码(可参考FAT12引导扇区的格式 https://zhuanlan.zhihu.com/p/121807427)(0,62)
    DB      0xeb,   0x4e,   0x90;BS_jmpBOOT(0,3)              jmp LABEL_START nop
    DB      "NOOBLOAD"          ;BS_OEMName(3,8)              启动区的名称可以是任意字符(8字节)厂商名
    DW      512                 ;BPB_BytesPerSec(11,2)        每个扇区(sector)的大小(必须是512字节)
    DB      1                   ;BPB_SecPerClus(13,1)         簇(cluster)windows/块(block)linux的大小(逻辑概念)
    DW      1                   ;BPB_ResvdSecCnt(14,2)        MBR占用扇区数
    DB      2                   ;BPB_NumFATs(16,1)            FAT的个数FAT的个数(共有多少个FAT表，必须是2)
    DW      224                 ;BPB_RootEntCnt(17,2)         根目录文件数的最大值(一般设置成224 0xe0)
    DW      2280                ;BPB_TotSec16(19,2)           该磁盘的大小(必须是2880 0xb40)
    DB      0xf0                ;BPB_Media(21,1)              介质描述符
    DW      9                   ;BPB_FATSz16(22,2)            一个FAT表所占的扇区数 9
    DW      18                  ;BPB_SecPerTrk(24,2)          每个磁道(track)所占的扇区数  18
    DW      2                   ;BPB_NumHeads(26,2)           磁头数 2
    DD      0                   ;BPB_HiddSec(28,4)            隐藏扇区数(不适用分区必须是0)
    DD      2880                ;BPB_TotSec32(32,4)           如果BPB_TotSec16=0,则这里给出扇区总数 2880
    DB      0                   ;BS_DrvNum(36,1)              INT 13H的驱动器号
    DB      0                   ;BS_Reserved1(37,1)           保留位
    DB      0x29                ;BS_BootSig(38,1)             扩展引导标记
    DD      0xffffffff          ;BS_VoIID(39,4)               卷序列号
    DB      "NOOB-OS    "       ;BS_VOILab(43,11)             卷标
    DB      "FAT12   "          ;BS_FileSysType(54,8)         文件系统类型,'FAT12'
    RESB    18                  ;空出18个字节(62,18)          ?这个地方为什么要空18个字节，不是很理解，但是不加就有问题
 
; 程序主体(80,36)
 	DB	    0xb8, 0x00, 0x00, 0x8e, 0xd0, 0xbc, 0x00, 0x7c
	DB	    0x8e, 0xd8, 0x8e, 0xc0, 0xbe, 0x74, 0x7c, 0x8a
	DB	    0x04, 0x83, 0xc6, 0x01, 0x3c, 0x00, 0x74, 0x09
	DB	    0xb4, 0x0e, 0xbb, 0x0f, 0x00, 0xcd, 0x10, 0xeb
	DB	    0xee, 0xf4, 0xeb, 0xfd
    
; 信息显示部分(116,412)
    DB      0x0a,  0x0a         ;两个换行
    DB      "hello, world"
    DB      0x0a                ;换行
    DB      0
    RESB    0x1fe-$             ;填写0x00，直到0x001fe(510)
 
; 启动区结束符(510,2)
    DB       0x55, 0xaa
 
; 启动区外(512,1868920)
	DB		0xf0, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00      ;一个FAT表是9个扇区也就是4608个字节,每个簇占12个字节,0和1簇不能使用，存储坏簇和结尾簇符号0xff0和0xfff(inter采用大端存储所以坏簇是0xf0f)
	RESB	4600                                                ;预留4600个字节补零
	DB		0xf0, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00      ;FAT表2
	RESB	1469432                                             ;预留1469432个字节补零