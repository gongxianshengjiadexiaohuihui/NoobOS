#命令行必须前必须是TAB，不能是空格，有些文本编辑器自动会将TAB替换成空格

#宏定义 在windows上指定shell为cmd chdir是windows上获取当前路径的命令
SHELL=cmd
DIR=$(shell chdir)

MAKE	=./tools/make.exe -r
IMG		=java -classpath ./tools/imgtool/ com.ggp.tools.FAT12tool
NASM	=./tools/nasm.exe
#-c生成obj文件 -nostdlib不连接系统标准启动文件和标准库文件.只把指定的文件传递给连接器. -Wall生成警告信息 -O3代码优化
GCC		=gcc -m32 -nostdlib -Wall -O3  -c

#默认行为 make的动作
default :
	$(MAKE) img

#镜像文件输出
img :ipl.bin noobos.sys Makefile
	$(IMG) $(DIR)\ipl.bin $(DIR)\noobos.sys $(DIR)\noobos.img

#启动区文件编译规则
ipl.bin :ipl.asm Makefile
	$(NASM) ipl.asm -o ipl.bin -l ipl.lst

#系统文件编译规则

#系统加载文件编译
bootload.bin :bootload.asm Makefile
	$(NASM) bootload.asm -o bootload.bin -l bootload.lst
#halt 空转函数 
haltfunc.obj :haltfunc.asm Makefile
	$(NASM) -fwin32 haltfunc.asm
#主函数，程序入口
bootpack.o :bootpack.c Makefile
	$(GCC) bootpack.c
#进行链接
#-m 指定模拟器 i386pe是32位 i386pep是64位
#-Map 打印一个连接位图到文件MAPFILE中,打印一个连接位图到标准输出.一个连接位图提供的关于连接的信息有如下一些:目标文件和符号被映射到内存的哪些地方.普通符号如何被分配空间.所有被连接进来的档案文件,还有导致档案文件被包含进来的那个符号.
#-e 指定程序的入口
#-n 关闭所有节的页对齐,如果可能,把输出格式标识为'NMAGIC'.
#-Ttext obj文件里面都是相对地址，这里就是给定相对于那个地址 0xc200在bootload中有设定
#-static 不连接共享库. 这个仅仅在支持共享库的平台上有用. 这个选项的不同形式是为了跟不同的系统保持兼容
bootpack.bin :bootpack.o haltfunc.obj Makefile
	ld -m i386pe -e _Main -Map bootpack.map -n -Ttext 0xc200 -static -o bootpack.bin bootpack.o haltfunc.obj
#二进制文件组装 /B 二进制文件
noobos.sys :bootload.bin bootpack.bin Makefile
	copy /B bootload.bin+bootpack.bin noobos.sys

#清除中间代码
clean :
	del *.bin
	del *.obj
	del *.o
	del *.lst
	del noobos.sys