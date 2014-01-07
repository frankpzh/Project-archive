#include <io.h>
#include <memory.h>

void sdram_init() {
	IO_SETBIT(MISCCR, 17, 0);
	IO_SETBIT(MISCCR, 18, 0);
	IO_SETBIT(MISCCR, 19, 0);
	DELAY(128);
}

void bus_init() {
	IO_WRITE(BWSCON, 0x2211d1d0);
	IO_WRITE(BANKCON0, 0x700);
	IO_WRITE(BANKCON1, 0x1bc0);
	IO_WRITE(BANKCON2, 0x700);
	IO_WRITE(BANKCON3, 0x1f4c);
	IO_WRITE(BANKCON4, 0x700);
	IO_WRITE(BANKCON5, 0x700);
	IO_WRITE(BANKCON6, 0x18005);
	IO_WRITE(BANKCON7, 0x18005);
	IO_WRITE(REFRESH, 0x9e012b);
	IO_WRITE(BANKSIZE, 0xb1);
	IO_WRITE(MRSRB6, 0x30);
	IO_WRITE(MRSRB7, 0x30);
	// setup asynchronous bus mode
	asm volatile (
		"mrc p15, 0, r0, c1, c0, 0\n"
		"orr r0, r0, #0xc0000000\n"
		"mcr p15, 0, r0, c1, c0, 0\n"
	);
	GPIO_SET(J, 8, GPIO_OUTPUT);
	GPIO_WRITE(J, 8, 1);
}

void memory_init() {
	sdram_init();
	bus_init();
	DELAY(0xfffff);
}
