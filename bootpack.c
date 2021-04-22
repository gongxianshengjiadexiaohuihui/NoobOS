void io_hlt(void);
void write_mem8(int addr,int data);
void NoobMain(void)
{
	int i;
	/*0xa00000-0xaffff是图形视频缓冲区,bootload定义的VRAM 写入15意思是全部像素的颜色是第15种颜色白色*/
	for(i=0xa0000; i<=0xaffff;i++){
		write_mem8(i,15);
	}
	
	for(;;){
		io_hlt();
	}
}
