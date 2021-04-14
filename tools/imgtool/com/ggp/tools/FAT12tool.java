package com.ggp.tools;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;

/**
 * @Author:ggp
 * @Date:2021/4/14 14:53
 * @Description:
 */
public class FAT12tool {
    public static void main(String[] args) throws Exception{
        String iplPath = args[0];
        String sysPath = args[1];
        String imgPath = args[2];
        FileInputStream ipl_is=new FileInputStream(new File(iplPath));
        FileInputStream sys_is=new FileInputStream(new File(sysPath));
        FileOutputStream img_os = new FileOutputStream(new File(imgPath));
        //软盘总大小1440K
        int totalLen = 1474560;
        //数据区开始地址0x4200
        int dataAreaBegin = 16896;
        //系统文件长度
        int sysLen = sys_is.available();
        for (int i = 0; i <totalLen ; i++) {
            if(i<512){
                img_os.write(ipl_is.read());
            }else if(i>=dataAreaBegin&&i<dataAreaBegin+sysLen){
                img_os.write(sys_is.read());
            }else{
                img_os.write(0);
            }
        }
    }
}
