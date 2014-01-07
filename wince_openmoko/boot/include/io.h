#ifndef __PIO_H__
#define __PIO_H__

#define IO_ADDR(addr) ((volatile unsigned *)(addr))
#define IO_ADDRB(addr) ((volatile unsigned char *)(addr))
#define IO_ADDRS(addr) ((volatile unsigned short *)(addr))
#define IO_READ(addr) (*IO_ADDR(addr))
#define IO_WRITE(addr, data) (*IO_ADDR(addr) = (data))
#define IO_READB(addr) (*IO_ADDRB(addr))
#define IO_WRITEB(addr, data) (*IO_ADDRB(addr) = (unsigned char)(data))
#define IO_READS(addr) (*IO_ADDRS(addr))
#define IO_WRITES(addr, data) (*IO_ADDRS(addr) = (unsigned short)(data))

#define IO_SETBITS(addr, base, mask, data) \
	IO_WRITE(addr, IO_READ(addr) & (~((mask) << (base))) | ((data) << (base)))
#define IO_SETBIT(addr, bit, data) IO_SETBITS(addr, bit, 1, data)
#define IO_GETBIT(addr, bit) ((IO_READ(addr) >> (bit)) & 1)

#define GPIO_SET(i1, i2, func) IO_SETBITS(GP##i1##CON, (i2) * 2, 0x3, func)
#define GPIO_READ(i1, i2) IO_GETBIT(GP##i1##DAT, i2)
#define GPIO_WRITE(i1, i2, data) IO_SETBIT(GP##i1##DAT, i2, data)

#define GPBCON		0x56000010
#define GPBDAT		0x56000014
#define GPCCON		0x56000020
#define GPCDAT		0x56000024
#define GPDCON		0x56000030
#define GPDDAT		0x56000034
#define GPECON		0x56000040
#define GPEDAT		0x56000044
#define GPFCON		0x56000050
#define GPFDAT		0x56000054
#define GPGCON		0x56000060
#define GPGDAT		0x56000064
#define GPHCON		0x56000070
#define GPHDAT		0x56000074
#define GPJCON		0x560000d0
#define GPJDAT		0x560000d4

#define GPIO_INPUT	0x0
#define GPIO_OUTPUT	0x1
#define GPIO_FUNC	0x2
#define GPIO_FUNC2	0x3

#define DELAY(insts)					\
	do {								\
		asm volatile(					\
			"	ldr r0, =" #insts "\n"	\
			"1:	subs r0, r0, #1\n"		\
			"	bpl 1b"					\
		);								\
	} while(0)

#endif
