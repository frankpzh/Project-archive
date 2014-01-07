#include <led.h>
#include <clock.h>
#include <uart.h>
#include <memory.h>

#define KERNEL 0x400

void init() {
	clock_init();
	uart_init();
	memory_init();
	flash_init();
	led_init();
}

unsigned int main() {
	led_set(3, 1);
	for (;;);
	unsigned char *mem = (unsigned char *)0x30000000;

	printf("Starting read flash...");
	flash_read(mem, KERNEL, 16);
	printf("Done\n");
	return 0x30000000;
}
