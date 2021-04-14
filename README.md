# FAT12格式

![preview](C:\Users\admin\Desktop\笔记\noobOS\NoobOS\img\v2-1c908247ddcfac45405ff5b7420a6138_r.jpg)

MBR:1个扇区

FAT1:9个扇区

FAT2:9个扇区

根目录区:14个扇区(一共224个文件，每个文件32位)

数据区:0x4200-0x16800

# 工具

## nask.exe

汇编的编译工具

## make.exe

根据Makefile中定义的规则进行编译

# 文件

## nas

汇编源文件

## lst

编译的中间产品.lst文件可用于排错 

## bin

二进制文件



# 注意

## makefile

* 命令行必须前必须是TAB，不能是空格，有些文本编辑器自动会将TAB替换成空格