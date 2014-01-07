#ifndef __CLOCK_H__
#define __CLOCK_H__

#define LOCKTIME	0x4c000000
#define MPLLCON		0x4c000004
#define UPLLCON		0x4c000008
#define CLKCON		0x4c00000c
#define CLKSLOW		0x4c000010
#define CLKDIVN		0x4c000014
#define CAMDIVN		0x4c000018

void clock_init();

#endif
