#include <io.h>
#include <uart.h>

void uart_init() {
	GPIO_SET(H, 6, GPIO_FUNC);
	GPIO_SET(H, 7, GPIO_FUNC);
	IO_WRITE(ULCON2, 0x3);
	IO_WRITE(UCON2, 0x5);
	IO_WRITE(UFCON2, 0);
	IO_WRITE(UBRDIV2, 26);
	GPIO_SET(J, 4, GPIO_OUTPUT);
	GPIO_WRITE(J, 4, 1);
}

void uart_putc(int ch) {
	if (ch == '\n')
		uart_putc('\r');
	while (!(IO_READ(UTRSTAT2) & 0x2));
	IO_WRITEB(UTXH2, ch & 0xff);
}

int uart_getc() {
	while (!(IO_READ(UTRSTAT2) & 0x1));
	return IO_READB(URXH2);
}
