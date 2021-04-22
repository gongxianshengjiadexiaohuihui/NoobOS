TOOLPATH = ./z_tools/
INCPATH  = ./z_tools/haribote/

MAKE     = $(TOOLPATH)make.exe -r
NASK     = $(TOOLPATH)nask.exe
CC1      = $(TOOLPATH)cc1.exe -I$(INCPATH) -Os -Wall -quiet
GAS2NASK = $(TOOLPATH)gas2nask.exe -a
OBJ2BIM  = $(TOOLPATH)obj2bim.exe
BIM2HRB  = $(TOOLPATH)bim2hrb.exe
RULEFILE = $(TOOLPATH)haribote/haribote.rul
EDIMG    = $(TOOLPATH)edimg.exe
IMGTOL   = $(TOOLPATH)imgtol.com
COPY     = copy
DEL      = del


default :
	$(MAKE) img

# 引导扇区代码编译
ipl.bin : ipl.asm Makefile
	$(NASK) ipl.asm ipl.bin ipl.lst
# 加载程序编译
bootload.bin : bootload.asm Makefile
	$(NASK) bootload.asm bootload.bin bootload.lst
# 引导程序编译 编译的是gas汇编
bootpack.gas : bootpack.c Makefile
	$(CC1) -o bootpack.gas bootpack.c
# 将gas汇编转为nask汇编
bootpack.nas : bootpack.gas Makefile
	$(GAS2NASK) bootpack.gas bootpack.nas
# 将nask编译为目标文件
bootpack.obj : bootpack.nas Makefile
	$(NASK) bootpack.nas bootpack.obj bootpack.lst
# 汇编写的函数编译，编译为目标文件
asmfunc.obj : asmfunc.asm Makefile
	$(NASK) asmfunc.asm asmfunc.obj asmfunc.lst
# 将目标文件进行链接
bootpack.bim : bootpack.obj asmfunc.obj Makefile
	$(OBJ2BIM) @$(RULEFILE) out:bootpack.bim stack:3136k map:bootpack.map \
		bootpack.obj asmfunc.obj
# 3MB+64KB=3136KB
#bim和hrb都是作者设计的文件格式，有自己的文件头和结构
bootpack.hrb : bootpack.bim Makefile
	$(BIM2HRB) bootpack.bim bootpack.hrb 0
#将引导程序和程序入口进行拼接
noobos.sys : bootload.bin bootpack.hrb Makefile
	copy /B bootload.bin+bootpack.hrb noobos.sys
#输出FAT12格式的32位镜像文件
img : ipl.bin noobos.sys Makefile
	$(EDIMG)   imgin:$(TOOLPATH)/fdimg0at.tek \
		wbinimg src:ipl.bin len:512 from:0 to:0 \
		copy from:noobos.sys to:@: \
		imgout:noobos.img


clean :
	-$(DEL) *.bin
	-$(DEL) *.lst
	-$(DEL) *.gas
	-$(DEL) *.obj
	-$(DEL) bootpack.nas
	-$(DEL) bootpack.map
	-$(DEL) bootpack.bim
	-$(DEL) bootpack.hrb
	-$(DEL) noobos.sys

