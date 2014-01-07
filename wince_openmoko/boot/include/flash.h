#ifndef __FLASH_H__
#define __FLASH_H__

#define NFCONF	0x4e000000
#define NFCONT	0x4e000004
#define NFCMMD	0x4e000008
#define NFADDR	0x4e00000c
#define NFDATA	0x4e000010
#define NFSTAT	0x4e000020

#define NAND_CMD_READ0 0
#define NAND_CMD_READSTART 0x30

void flash_init();
int flash_read(unsigned char *buf, unsigned long start_block512, int blocks512);

#endif
