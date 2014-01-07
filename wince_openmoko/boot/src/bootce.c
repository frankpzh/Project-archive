#include <clock.h>
#include <uart.h>
#include <memory.h>

#define ROOTFS 0x4b00

struct flash {
	int i, j;
	unsigned char *mem;
};

void init() {
	clock_init();
	uart_init();
	memory_init();
	flash_init();
}

void read(void *buff, int size, struct flash *f) {
	unsigned char *buf = (unsigned char *)buff;
	while (size) {
		if (!f->j)
			flash_read(f->mem, f->i, 1);
		if (size >= 512 - f->j) {
			memmove(buf, &f->mem[f->j], 512 - f->j);
			buf += 512 - f->j;
			size -= 512 - f->j;
			f->j = 0;
			f->i++;
		}
		else {
			memmove(buf, &f->mem[f->j], size);
			f->j += size;
			size = 0;
		}
	}
}

unsigned int main() {
	unsigned char buf[8];
	unsigned int img_addr, img_len, entry;
	struct flash f = {
		ROOTFS,
		0,
		(unsigned char *)0x37fffe00,
	};

	read(buf, 7, &f);
	if (memcmp(buf, "B000FF\n", 7)) {
		printf("Not a valid WinCE image.\n");
		buf[7] = '\0';
		goto unhappy;
	}
	read(&img_addr, 4, &f);
	read(&img_len, 4, &f);
	printf("Find WinCE image. Address: 0x%x, size: 0x%x.\n", img_addr, img_len);
	while (1) {
		unsigned int rec_addr, rec_len, rec_csum;

		read(&rec_addr, 4, &f);
		read(&rec_len, 4, &f);
		read(&rec_csum, 4, &f);
		printf("Read WinCE image piece. Address: 0x%x, size: 0x%x.\n", rec_addr, rec_len);
		if (!rec_addr) {
			entry = rec_len;
			break;
		}
		read((void *)(rec_addr - img_addr + 0x30000000), rec_len, &f);
	}
	printf("Entry address: 0x%x.\n", entry - img_addr + 0x30000000);
	return entry - img_addr + 0x30000000;
unhappy:
	while (1);
}
