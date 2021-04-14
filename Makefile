#命令行必须前必须是TAB，不能是空格，有些文本编辑器自动会将TAB替换成空格

#宏定义 在windows上指定shell为cmd chdir是windows上获取当前路径的命令
SHELL=cmd
DIR=$(shell chdir)

#默认行为 make的动作
default :
	./tools/make.exe -r img

#镜像文件输出
img :ipl.bin noobos.bin Makefile
	java -classpath ./tools/imgtool/ com.ggp.tools.FAT12tool $(DIR)\ipl.bin $(DIR)\noobos.bin $(DIR)\noobos.img

#启动区文件编译规则

#需要准备的源文件 ipl.nas Makefile
ipl.bin :ipl.nas Makefile
	./tools/nasm.exe ipl.nas -o ipl.bin -l ipl.lst

#系统文件编译规则

#需要准备的源文件
noobos.bin :noobos.nas Makefile
	./tools/nasm.exe noobos.nas -o noobos.bin -l noobos.lst