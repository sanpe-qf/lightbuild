/*********************************************************************
* 版权所有 (C)2017, ileyun.org
* 
* 文件名称： //main.c
* 文件标识： // 
* 内容摘要： // main函数
* 其它说明： // 主函数
* 当前版本： // v1.1
* 作    者： // 我在做梦<345340585@qq.com>
* 完成日期： // 2017/08/29
* 
* 修改日期        版本号     修改人	      修改内容
* ---------------------------------------------------------------
* 2017/08/29	     V1.1	   *************************************/
#include "main.h"

int a = 0;
int main()
{
	initStatusLed();
    turnOn(); 
    while(a){
        turnOff();
    }
	return 0;
}
void initPwrLed(){
	GPIOL_CONFIG1= 0x11<<8;
	GPIOL_CONFIG1|= 0x11<<0;
}
void initStatusLed(){
	GPIOA_CONFIG2= 0x77<<16;
	GPIOA_CONFIG2|= 0x77<<8;
	GPIOA_CONFIG2|= 0x17<<0;
}
void turnOn(){
	GPIOA_DATA = 1<<17; 
	GPIOL_DATA = 0xFFF;
}
void turnOff(){
	 
	GPIOA_DATA = 0<<17; 
	GPIOL_DATA = 0x0;
}

