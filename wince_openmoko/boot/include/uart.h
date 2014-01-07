#ifndef __UART_H__
#define __UART_H__

#define ULCON2		0x50008000
#define UCON2		0x50008004
#define UFCON2		0x50008008
#define UTRSTAT2	0x50008010
#define UERSTAT2	0x50008014
#define UFSTAT2		0x50008018
#define UTXH2		0x50008020
#define URXH2		0x50008024
#define UBRDIV2		0x50008028

void uart_init();
void uart_putc(int ch);
int uart_getc();

#endif
