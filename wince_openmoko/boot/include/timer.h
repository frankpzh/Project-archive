#ifndef __TIMER_H__
#define __TIMER_H__

#include <io.h>

#define	TCFG0			0x51000000
#define TCFG1			0x51000004
#define TCON			0x51000008

#define TCON_T3START	0x00010000 	
#define TCON_T3INVERT	0x00020000 	
#define TCON_T3RELOAD	0x00040000 	

#define TCNTB3			0x51000030
#define TCMPB3			0x51000034

#endif
