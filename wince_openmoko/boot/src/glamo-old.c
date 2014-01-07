#include <io.h>
#include <glamo.h>
#include <glamo-regs.h>	

#define GLAMO_LCD_WIDTH_MASK 0x03FF
#define GLAMO_LCD_HEIGHT_MASK 0x03FF
#define GLAMO_LCD_PITCH_MASK 0x07FE
#define GLAMO_LCD_HV_TOTAL_MASK 0x03FF
#define GLAMO_LCD_HV_RETR_START_MASK 0x03FF
#define GLAMO_LCD_HV_RETR_END_MASK 0x03FF
#define GLAMO_LCD_HV_RETR_DISP_START_MASK 0x03FF
#define GLAMO_LCD_HV_RETR_DISP_END_MASK 0x03FF

static void __reg_set_bit_mask(unsigned int reg, unsigned short mask, unsigned short val)
{
	volatile unsigned short tmp;

	val &= mask;

	tmp = IO_READS(reg);
	tmp &= ~mask;
	tmp |= val;
	IO_WRITES(reg, tmp);
}

struct glamo_script lcd_script[] = {
	{ GLAMO_REG_LCD_MODE1, 0x0020 },
	/* no display rotation, no hardware cursor, no dither, no gamma,
	 * no retrace flip, vsync low-active, hsync low active,
	 * no TVCLK, no partial display, hw dest color from fb,
	 * no partial display mode, LCD1, software flip,  */
	{ GLAMO_REG_LCD_MODE2, 0x9020 },
	  /* video flip, no ptr, no ptr, dhclk off,
	   * normal mode,  no cpuif,
	   * res, serial msb first, single fb, no fr ctrl,
	   * cpu if bits all zero, no crc
	   * 0000 0000 0010  0000 */
	{ GLAMO_REG_LCD_MODE3, 0x0b40 },
	  /* src data rgb565, res, 18bit rgb666
	   * 000 01 011 0100 0000 */
	{ GLAMO_REG_LCD_POLARITY, 0x440c },
	  /* DE high active, no cpu/lcd if, cs0 force low, a0 low active,
	   * np cpu if, 9bit serial data, sclk rising edge latch data
	   * 01 00 0 100 0 000 01 0 0 */
	/* The following values assume 640*480@16bpp */
	{ GLAMO_REG_LCD_A_BASE1, 0x0000 }, /* display A base address 15:0 */
	{ GLAMO_REG_LCD_A_BASE2, 0x0000 }, /* display A base address 22:16 */
	{ GLAMO_REG_LCD_B_BASE1, 0x6000 }, /* display B base address 15:0 */
	{ GLAMO_REG_LCD_B_BASE2, 0x0009 }, /* display B base address 22:16 */
	{ GLAMO_REG_LCD_CURSOR_BASE1, 0xC000 }, /* cursor base address 15:0 */
	{ GLAMO_REG_LCD_CURSOR_BASE2, 0x0012 }, /* cursor base address 22:16 */
	{ GLAMO_REG_LCD_COMMAND2, 0x0000 }, /* display page A */
};

struct glamo_script chip_script[] = {
	{ GLAMO_REG_CLOCK_HOST,		0x1000 },
		{ 0xfffe, 2 },
	{ GLAMO_REG_CLOCK_MEMORY, 	0x1000 },
	{ GLAMO_REG_CLOCK_MEMORY,	0x2000 },
	{ GLAMO_REG_CLOCK_LCD,		0x1000 },
	{ GLAMO_REG_CLOCK_MMC,		0x1000 },
	{ GLAMO_REG_CLOCK_ISP,		0x1000 },
	{ GLAMO_REG_CLOCK_ISP,		0x3000 },
	{ GLAMO_REG_CLOCK_JPEG,		0x1000 },
	{ GLAMO_REG_CLOCK_3D,		0x1000 },
	{ GLAMO_REG_CLOCK_3D,		0x3000 },
	{ GLAMO_REG_CLOCK_2D,		0x1000 },
	{ GLAMO_REG_CLOCK_2D,		0x3000 },
	{ GLAMO_REG_CLOCK_RISC1,	0x1000 },
	{ GLAMO_REG_CLOCK_MPEG,		0x3000 },
	{ GLAMO_REG_CLOCK_MPEG,		0x3000 },
	{ GLAMO_REG_CLOCK_MPROC,	0x1000 /*0x100f*/ },
		{ 0xfffe, 2 },
	{ GLAMO_REG_CLOCK_HOST,		0x0000 },
	{ GLAMO_REG_CLOCK_MEMORY,	0x0000 },
	{ GLAMO_REG_CLOCK_LCD,		0x0000 },
	{ GLAMO_REG_CLOCK_MMC,		0x0000 },
	{ GLAMO_REG_PLL_GEN1,		0x05db },	/* 48MHz */
	{ GLAMO_REG_PLL_GEN3,		0x0aba },	/* 90MHz */
	{ 0xfffd, 0 },
	/*
	 * b9 of this register MUST be zero to get any interrupts on INT#
	 * the other set bits enable all the engine interrupt sources
	 */
	{ GLAMO_REG_IRQ_ENABLE,		0x01ff },
	{ GLAMO_REG_CLOCK_GEN6,		0x2000 },
	{ GLAMO_REG_CLOCK_GEN7,		0x0101 },
	{ GLAMO_REG_CLOCK_GEN8,		0x0100 },
	{ GLAMO_REG_CLOCK_HOST,		0x000d },
	/*
	 * b7..b4 = 0 = no wait states on read or write
	 * b0 = 1 select PLL2 for Host interface, b1 = enable it
	 */
	{ 0x200,	0x0e03 /* this is replaced by script parser */ },
	{ 0x202, 	0x07ff },
	{ 0x212,	0x0000 },
	{ 0x214,	0x4000 },
	{ 0x216,	0xf00e },

	/* S-Media recommended "set tiling mode to 512 mode for memory access
	 * more efficiency when 640x480" */
	{ GLAMO_REG_MEM_TYPE,		0x0c74 }, /* 8MB, 16 word pg wr+rd */
	{ GLAMO_REG_MEM_GEN,		0xafaf }, /* 63 grants min + max */

	{ GLAMO_REGOFS_HOSTBUS + 2,	0xffff }, /* enable  on MMIO*/

	{ GLAMO_REG_MEM_TIMING1,	0x0108 },
	{ GLAMO_REG_MEM_TIMING2,	0x0010 }, /* Taa = 3 MCLK */
	{ GLAMO_REG_MEM_TIMING3,	0x0000 },
	{ GLAMO_REG_MEM_TIMING4,	0x0000 }, /* CE1# delay fall/rise */
	{ GLAMO_REG_MEM_TIMING5,	0x0000 }, /* UB# LB# */
	{ GLAMO_REG_MEM_TIMING6,	0x0000 }, /* OE# */
	{ GLAMO_REG_MEM_TIMING7,	0x0000 }, /* WE# */
	{ GLAMO_REG_MEM_TIMING8,	0x1002 }, /* MCLK delay, was 0x1000 */
	{ GLAMO_REG_MEM_TIMING9,	0x6006 },
	{ GLAMO_REG_MEM_TIMING10,	0x00ff },
	{ GLAMO_REG_MEM_TIMING11,	0x0001 },
	{ GLAMO_REG_MEM_POWER1,		0x0020 },
	{ GLAMO_REG_MEM_POWER2,		0x0000 },
	{ GLAMO_REG_MEM_DRAM1,		0x0000 },
		{ 0xfffe, 1 },
	{ GLAMO_REG_MEM_DRAM1,		0xc100 },
		{ 0xfffe, 1 },
	{ GLAMO_REG_MEM_DRAM1,		0xe100 },
	{ GLAMO_REG_MEM_DRAM2,		0x01d6 },
	{ GLAMO_REG_CLOCK_MEMORY,	0x000b },
	{ GLAMO_REG_GPIO_GEN1,		0x000f },
	{ GLAMO_REG_GPIO_GEN2,		0x111e },
	{ GLAMO_REG_GPIO_GEN3,		0xccc3 },
	{ GLAMO_REG_GPIO_GEN4,		0x111e },
	{ GLAMO_REG_GPIO_GEN5,		0x000f }
};

void glamo_engine_init() {
	__reg_set_bit_mask(GLAMO_BASE + GLAMO_REG_HOSTBUS(2),
			   GLAMO_HOSTBUS2_MMIO_EN_LCD,
			   GLAMO_HOSTBUS2_MMIO_EN_LCD);
	IO_WRITES(GLAMO_BASE + GLAMO_REG_CLOCK_LCD,
		    GLAMO_CLOCK_LCD_EN_M5CLK |
		    GLAMO_CLOCK_LCD_EN_DHCLK |
		    GLAMO_CLOCK_LCD_EN_DMCLK |
		    GLAMO_CLOCK_LCD_EN_DCLK |
		    GLAMO_CLOCK_LCD_DG_M5CLK |
		    GLAMO_CLOCK_LCD_DG_DMCLK);
	__reg_set_bit_mask(GLAMO_BASE + GLAMO_REG_CLOCK_GEN5_1,
		    GLAMO_CLOCK_GEN51_EN_DIV_DHCLK |
		    GLAMO_CLOCK_GEN51_EN_DIV_DMCLK |
		    GLAMO_CLOCK_GEN51_EN_DIV_DCLK, 0xffff);
}

void glamo_run_script(struct glamo_script *script, int len) {
	volatile int i, j;

	for (i = 0; i < len; i++) {
		struct glamo_script *line = &script[i];

		switch (line->reg) {
		case 0xffff:
			return;
		case 0xfffe:
			for (j = 0; j < line->val; j++)
				DELAY(3000);
			break;
		case 0xfffd:
			/* spin until PLLs lock */
			printf("waiting...\n");
			while ((IO_READS(GLAMO_BASE + GLAMO_REG_PLL_GEN5) & 0x3) != 0x3);
			printf("waiting done\n");
			break;
		default:
			IO_WRITES(GLAMO_BASE + script[i].reg, script[i].val);
			break;
		}
	}
}

inline int glamo_cmdq_empty()
{
	return IO_READS(GLAMO_BASE + GLAMO_REG_LCD_STATUS1) & (1 << 15);
}

int glamo_cmd_mode(int on)
{
	int timeout = 2000000;

	if (on) {
		while ((!glamo_cmdq_empty()) && (timeout--));
		if (timeout < 0)
			return -1;

		/* display the entire frame then switch to command */
		IO_WRITES(GLAMO_BASE + GLAMO_REG_LCD_COMMAND1,
			  GLAMO_LCD_CMD_TYPE_DISP |
			  GLAMO_LCD_CMD_DATA_FIRE_VSYNC);

		/* wait until lcd idle */
		timeout = 2000000;
		while ((!IO_READS(GLAMO_BASE + GLAMO_REG_LCD_STATUS2) & (1 << 12)) && (timeout--));
		if (timeout < 0)
			return -1;

		DELAY(300000);
	} else {
		/* RGB interface needs vsync/hsync */
		if (IO_READS(GLAMO_BASE + GLAMO_REG_LCD_MODE3) & GLAMO_LCD_MODE3_RGB)
			IO_WRITES(GLAMO_BASE + GLAMO_REG_LCD_COMMAND1,
				  GLAMO_LCD_CMD_TYPE_DISP |
				  GLAMO_LCD_CMD_DATA_DISP_SYNC);

		IO_WRITES(GLAMO_BASE + GLAMO_REG_LCD_COMMAND1,
			  GLAMO_LCD_CMD_TYPE_DISP |
			  GLAMO_LCD_CMD_DATA_DISP_FIRE);
	}

	return 0;
}

int glamo_engine_reclock(int ps)
{
	int pll, khz;
	unsigned short val = 0;

	if (!ps)
		return 0;

	pll = 32768 * IO_READS(GLAMO_BASE + GLAMO_REG_PLL_GEN1);
	khz = div(1000000000UL, ps);

	if (khz)
		val = div(div(pll, khz), 1000);

	if (val) {
		val--;
		__reg_set_bit_mask(GLAMO_BASE + GLAMO_REG_CLOCK_GEN7, 0xff, val);
		DELAY(15000); /* wait some time to stabilize */

		return 0;
	}
	return -1;
}

void glamo_update_lcd()
{
	int xres = 480, yres=640, pitch = xres * 16 / 8, sync, bp, disp, fp, total;

	if (glamo_cmd_mode(1))
		return;

	glamo_engine_reclock(40816);

	__reg_set_bit_mask(GLAMO_BASE + GLAMO_REG_LCD_WIDTH,
			 GLAMO_LCD_WIDTH_MASK,
			 xres);
	__reg_set_bit_mask(GLAMO_BASE + GLAMO_REG_LCD_HEIGHT,
			 GLAMO_LCD_HEIGHT_MASK,
			 yres);
	__reg_set_bit_mask(GLAMO_BASE + GLAMO_REG_LCD_PITCH,
			 GLAMO_LCD_PITCH_MASK,
			 pitch);

	/* update scannout timings */
	sync = 0;
	bp = sync + 8;
	disp = bp + 8;
	fp = disp + xres;
	total = fp + 16;

	__reg_set_bit_mask(GLAMO_BASE + GLAMO_REG_LCD_HORIZ_TOTAL,
			 GLAMO_LCD_HV_TOTAL_MASK, total);
	__reg_set_bit_mask(GLAMO_BASE + GLAMO_REG_LCD_HORIZ_RETR_START,
			 GLAMO_LCD_HV_RETR_START_MASK, sync);
	__reg_set_bit_mask(GLAMO_BASE + GLAMO_REG_LCD_HORIZ_RETR_END,
			 GLAMO_LCD_HV_RETR_END_MASK, bp);
	__reg_set_bit_mask(GLAMO_BASE + GLAMO_REG_LCD_HORIZ_DISP_START,
			  GLAMO_LCD_HV_RETR_DISP_START_MASK, disp);
	__reg_set_bit_mask(GLAMO_BASE + GLAMO_REG_LCD_HORIZ_DISP_END,
			 GLAMO_LCD_HV_RETR_DISP_END_MASK, fp);

	sync = 0;
	bp = sync + 2;
	disp = bp + 2;
	fp = disp + yres;
	total = fp + 16;

	__reg_set_bit_mask(GLAMO_BASE + GLAMO_REG_LCD_VERT_TOTAL,
			 GLAMO_LCD_HV_TOTAL_MASK, total);
	__reg_set_bit_mask(GLAMO_BASE + GLAMO_REG_LCD_VERT_RETR_START,
			  GLAMO_LCD_HV_RETR_START_MASK, sync);
	__reg_set_bit_mask(GLAMO_BASE + GLAMO_REG_LCD_VERT_RETR_END,
			 GLAMO_LCD_HV_RETR_END_MASK, bp);
	__reg_set_bit_mask(GLAMO_BASE + GLAMO_REG_LCD_VERT_DISP_START,
			 GLAMO_LCD_HV_RETR_DISP_START_MASK, disp);
	__reg_set_bit_mask(GLAMO_BASE + GLAMO_REG_LCD_VERT_DISP_END,
			 GLAMO_LCD_HV_RETR_DISP_END_MASK, fp);

	glamo_cmd_mode(0);
}


void glamo_init() {
	GPIO_SET(J, 5, GPIO_OUTPUT);
	GPIO_WRITE(J, 5, 0);
	printf("sleeping...\n");
	DELAY(30000);
	printf("sleeping done\n");
	GPIO_WRITE(J, 5, 1);
	printf("sleeping...\n");
	DELAY(30000);
	printf("sleeping done\n");
	glamo_run_script(chip_script, sizeof(chip_script) / sizeof(struct glamo_script));
	glamo_engine_init();
	IO_SETBIT(GLAMO_BASE + GLAMO_REG_CLOCK_LCD, 12, 1);
	IO_SETBIT(GLAMO_BASE + GLAMO_REG_CLOCK_LCD, 12, 0);
	glamo_run_script(lcd_script, sizeof(lcd_script) / sizeof(struct glamo_script));
	printf("update_lcd\n");
	glamo_update_lcd();
	printf("update done\n");
}
