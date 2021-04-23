//CPU暂停
void io_hlt(void);
//禁止中断
void io_cli(void);
//向指定端口号写入一个字节
void io_out8(int port, int data);
//读取标志寄存器
int  io_load_eflags(void);
//更新标志寄存器
void io_store_eflags(int eflags);
//初始化调色板
void init_palette(void);
//设置调色板号
void set_palette(int start, int end, unsigned char *rgb);
//画矩形
//vram内存地址 xsize矩形的长，c,调色板号，x0,y0矩形左上角坐标，x1,y1，矩形右下角坐标。
void boxfill8(unsigned char *vram, int xsize, unsigned char c, int x0, int y0, int x1, int y1);
//宏定义
#define COL8_000000		0
#define COL8_FF0000		1
#define COL8_00FF00		2
#define COL8_FFFF00		3
#define COL8_0000FF		4
#define COL8_FF00FF		5
#define COL8_00FFFF		6
#define COL8_FFFFFF		7
#define COL8_C6C6C6		8
#define COL8_840000		9
#define COL8_008400		10
#define COL8_848400		11
#define COL8_000084		12
#define COL8_840084		13
#define COL8_008484		14
#define COL8_848484		15
void NoobMain(void)
{   

	//用于BYTE[]类地址,*的作用应该就是指明MOV 向目标地址转移内容的字节数有BYTE WORD DWORD
	char *vram;
	int xsize,ysize;
	init_palette();
	//0xa00000-0xaffff是图形视频缓冲区,bootload定义的VRAM 写入15意思是全部像素的颜色是第15种颜色白色
	vram=(char *)0xa0000;
    xsize=320;
	ysize=200;
    //320*172的矩形（0，0）到(319,171) 浅暗蓝 
	boxfill8(vram, xsize, COL8_008484,  0,         0,          xsize -  1, ysize - 29);
	//320*1的线条   (0,172)到(319,172) 亮灰
	boxfill8(vram, xsize, COL8_C6C6C6,  0,         ysize - 28, xsize -  1, ysize - 28);
	//320*1的线条	(0,173)到(319,173) 白
	boxfill8(vram, xsize, COL8_FFFFFF,  0,         ysize - 27, xsize -  1, ysize - 27);
	//320*26的矩形  (0,174)到(319,199) 亮灰
	boxfill8(vram, xsize, COL8_C6C6C6,  0,         ysize - 26, xsize -  1, ysize -  1);
    
	//57*1的线条    (3,176)到(59,176) 白
	boxfill8(vram, xsize, COL8_FFFFFF,  3,         ysize - 24, 59,         ysize - 24);
	//1*21的线条    (2,176)到(2,196)  白
	boxfill8(vram, xsize, COL8_FFFFFF,  2,         ysize - 24,  2,         ysize -  4);
	//57*1的线条    (3,196)到(59,196) 暗灰
	boxfill8(vram, xsize, COL8_848484,  3,         ysize -  4, 59,         ysize -  4);
	//1*19的线条    (59,177)到(59,195) 暗灰
	boxfill8(vram, xsize, COL8_848484, 59,         ysize - 23, 59,         ysize -  5);
	//58*1的线条    (2,197)到(59,197) 黑
	boxfill8(vram, xsize, COL8_000000,  2,         ysize -  3, 59,         ysize -  3);
	//1*22的线条    (60,176)到(60,197) 黑
	boxfill8(vram, xsize, COL8_000000, 60,         ysize - 24, 60,         ysize -  3);

    //44*1的线条    (273,176)到(316,176) 暗灰
	boxfill8(vram, xsize, COL8_848484, xsize - 47, ysize - 24, xsize -  4, ysize - 24);
	//1*20的线条    (273,177)到(273,196) 暗灰
	boxfill8(vram, xsize, COL8_848484, xsize - 47, ysize - 23, xsize - 47, ysize -  4);
	//44*1的线条    (273,196)到(316,196) 黑
	boxfill8(vram, xsize, COL8_FFFFFF, xsize - 47, ysize -  3, xsize -  4, ysize -  3);
	//1*22的线条    (317,176)到(317,197) 黑
	boxfill8(vram, xsize, COL8_FFFFFF, xsize -  3, ysize - 24, xsize -  3, ysize -  3);

	for(;;){
		io_hlt();
	}
}
//初始化调色版
void init_palette(void)
{
	//c语言中的static char语句只能用于数据，相当于汇编中的DB指令，占坑
	   static unsigned char table_rgb[16 * 3] = {
        0x00, 0x00, 0x00,   // #000000:黑 
        0xff, 0x00, 0x00,   // #ff0000:亮红 
        0x00, 0xff, 0x00,   // #00ff00:亮绿
        0xff, 0xff, 0x00,   // #ffff00:亮黄
        0x00, 0x00, 0xff,   // #0000ff:亮蓝　 
        0xff, 0x00, 0xff,   // #0000ff:亮蓝　 
        0x00, 0xff, 0xff,   // #00ffff:浅亮蓝 
        0xff, 0xff, 0xff,   // #ffffff:白 
        0xc6, 0xc6, 0xc6,   // #c6c6c6:亮灰 
        0x84, 0x00, 0x00,   // #840000:暗红 
        0x00, 0x84, 0x00,   // #008400:暗绿 
        0x84, 0x84, 0x00,   // #848400:暗黄
        0x00, 0x00, 0x84,   // #000084:暗蓝 
        0x84, 0x00, 0x84,   // #840084:暗紫 
        0x00, 0x84, 0x84,   // #008484:浅暗蓝 
        0x84, 0x84, 0x84    // #848484:暗灰 
    };
	set_palette(0,15,table_rgb);
	return;
}
//设定调色板
void set_palette(int start, int end, unsigned char *rgb)
{
	int i,eflags;
	eflags = io_load_eflags();//记录标志寄存器的值
	io_cli();				//禁止中断
	io_out8(0x03c8,start);
	for(i = start;i<=end;i++){
		io_out8(0x03c9,rgb[0]/4);
		io_out8(0x03c9,rgb[1]/4);
		io_out8(0x03c9,rgb[2]/4);
		rgb+=3;
	}
	io_store_eflags(eflags);//恢复标志寄存器的值
	return;
}
//画矩形
//x=320,y=200情况下，左上角坐标是(0,0),右下角坐标(319,199) 像素地址=0xa0000+x+y*320;
//vram内存地址 xsize矩形的长，c,调色板号，x0,y0矩形左上角坐标，x1,y1，矩形右下角坐标。
void boxfill8(unsigned char *vram, int xsize, unsigned char c, int x0, int y0, int x1, int y1)
{
	int x,y;
	for(y=y0; y<=y1;y++){
		for(x=x0;x<x1;x++){
			vram[y*xsize+x] = c;
		}
	}
	return;
}
