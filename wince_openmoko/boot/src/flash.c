#include <io.h>
#include <flash.h>

#define flash_select() IO_SETBIT(NFCONT, 1, 0)
#define flash_deselect() IO_SETBIT(NFCONT, 1, 1)
#define flash_clear_RnB() IO_SETBIT(NFSTAT, 2, 1)

#define NAND_PAGE_SIZE		2048
#define BAD_BLOCK_OFFSET	NAND_PAGE_SIZE
#define	NAND_BLOCK_MASK		(NAND_PAGE_SIZE - 1)
#define NAND_BLOCK_SIZE		(NAND_PAGE_SIZE * 64)

inline void flash_wait() {
	while (!IO_GETBIT(NFSTAT, 0))
		DELAY(30);
}

void flash_init() {
	IO_SETBITS(NFCONF, 4, 0x7, 0x7);
	IO_SETBITS(NFCONF, 8, 0x7, 0x7);
	IO_SETBITS(NFCONF, 12, 0x3, 0x3);
	IO_SETBIT(NFCONT, 0, 1);
}

int flash_bad_block(unsigned long block_index)
{
	volatile unsigned char data;
	volatile unsigned long page_num;

	flash_clear_RnB();
	page_num = block_index >> 2; /* addr / 2048 */
	IO_WRITEB(NFCMMD, NAND_CMD_READ0);
	IO_WRITEB(NFADDR, BAD_BLOCK_OFFSET & 0xff);
	IO_WRITEB(NFADDR, (BAD_BLOCK_OFFSET >> 8) & 0xff);
	IO_WRITEB(NFADDR, page_num & 0xff);
	IO_WRITEB(NFADDR, (page_num >> 8) & 0xff);
	IO_WRITEB(NFADDR, (page_num >> 16) & 0xff);
	IO_WRITEB(NFCMMD, NAND_CMD_READSTART);
	flash_wait();
	data = IO_READB(NFDATA);

	if (data != 0xff)
		return 1;

	return 0;
}

int flash_read_page(unsigned char *buf, unsigned long block512, int blocks512)
{
	volatile unsigned short *ptr16 = (unsigned short *)buf;
	volatile unsigned int i, page_num;
	volatile unsigned int block_amount;
	volatile int blocks_possible = (3 - (block512 & 3)) + 1;


	if (blocks512 > blocks_possible)
		blocks512 = blocks_possible;

	block_amount = (NAND_PAGE_SIZE / 4 / 2) * blocks512;

	flash_clear_RnB();

	IO_WRITEB(NFCMMD, NAND_CMD_READ0);

	page_num = block512 >> 2; /* 512 block -> 2048 block */
	/* Write Address */
	IO_WRITEB(NFADDR, 0);
	IO_WRITEB(NFADDR, (block512 & 3) << 1); /* which 512 block in 2048 */
	IO_WRITEB(NFADDR, page_num & 0xff);
	IO_WRITEB(NFADDR, (page_num >> 8) & 0xff);
	IO_WRITEB(NFADDR, (page_num >> 16) & 0xff);
	IO_WRITEB(NFCMMD, NAND_CMD_READSTART);
	flash_wait();

	for (i = 0; i < block_amount; i++)
		*ptr16++ = IO_READS(NFDATA);

	return blocks512;
}


/* low level nand read function */
int flash_read(unsigned char *buf, unsigned long start_block512,
								  int blocks512)
{
	volatile int i, j;
	volatile int bad_count = 0;

	/* chip Enable */
	flash_select();
	flash_clear_RnB();

	DELAY(10);

	while (blocks512 > 0) {
		if (flash_bad_block(start_block512) ||
				flash_bad_block(start_block512 + 4)) {
			start_block512 += 4;
			blocks512 += 4;
			if (bad_count++ == 4)
				return -1;
			continue;
		}

		j = flash_read_page(buf, start_block512, blocks512);
		start_block512 += j;
		buf += j << 9;
		blocks512 -= j;
	}


	/* chip Disable */
	flash_deselect();

	return 0;
}

