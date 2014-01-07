#include <io.h>
#include <clock.h>

// After initialization:
// FCLK: 400MHz
// HCLK: 100MHz
// PCLK: 50MHz
// UCLK: 48MHz
void clock_init() {
	IO_WRITE(CLKDIVN, 0x00000005);
	IO_WRITE(CLKCON, 0x00fffff0);
	IO_WRITE(UPLLCON, 0x00058042);
	asm __volatile__ (
		"nop\n"
		"nop\n"
		"nop\n"
		"nop\n"
		"nop\n"
		"nop\n"
		"nop\n"
	);
	IO_WRITE(MPLLCON, 0x0002a010);
}
