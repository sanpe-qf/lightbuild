/*********************************************************************
* 版权所有 (C)2017, ileyun.org
* 
* 文件名称： //main.h
* 文件标识： // 
* 内容摘要： // main头文件
* 其它说明： // 主函数
* 当前版本： // v1.1
* 作    者： // 我在做梦<345340585@qq.com>
* 完成日期： // 2017/08/29
* 
* 修改日期        版本号     修改人	      修改内容
* ---------------------------------------------------------------
* 2017/08/29	     V1.1	   *************************************/
 
#define GPIOA_CONFIG2  (*(volatile unsigned long *)0x01C20808)
#define GPIOA_DATA (*(volatile unsigned long *)0x01C20810) 
#define GPIOA_PUL1 (*(volatile unsigned long *)0x01C20820)


#define GPIOL_CONFIG1  (*(volatile unsigned long *)0x01F02C04)
#define GPIOL_DATA (*(volatile unsigned long *)0x01F02C10)
#define GPIOL_PUL0 (*(volatile unsigned long *)0x01F02C1C)

void Waitdelay(unsigned long delay);
void turnOn();
void turnOff();
void initStatusLed();
void initPwrLed();
