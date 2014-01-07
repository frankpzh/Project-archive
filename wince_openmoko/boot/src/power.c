#include <power.h>
#include <i2c.h>

#define PCF50633_I2C_ADDR		0x73
#define ARRAY_SIZE(x) (sizeof(x)/sizeof((x)[0]))

const unsigned char pcf50633_initial_regs[__NUM_PCF50633_REGS] = {
	/* gap */
	[PCF50633_REG_INT1M]	= 0x00,
	[PCF50633_REG_INT2M]	= PCF50633_INT2_EXTON3F |
				  PCF50633_INT2_EXTON3R |
				  PCF50633_INT2_EXTON2F |
				  PCF50633_INT2_EXTON2R,
	[PCF50633_REG_INT3M]	= PCF50633_INT3_ADCRDY,
	[PCF50633_REG_INT4M]	= 0x00,
	[PCF50633_REG_INT5M]	= 0x00,

	[PCF50633_REG_OOCWAKE]	= 0xd3, /* wake from ONKEY,EXTON!,RTC,USB,ADP */
	[PCF50633_REG_OOCTIM1]	= 0xaa,	/* debounce 14ms everything */
	[PCF50633_REG_OOCTIM2]	= 0x4a,
	[PCF50633_REG_OOCMODE]	= 0x55,
	[PCF50633_REG_OOCCTL]	= 0x47,

	[PCF50633_REG_GPIOCTL]	= 0x01,	/* only GPIO1 is input */
	[PCF50633_REG_GPIO2CFG]	= 0x00,
	[PCF50633_REG_GPIO3CFG]	= 0x00,
	[PCF50633_REG_GPOCFG]	= 0x00,

	[PCF50633_REG_SVMCTL]	= 0x08,	/* 3.10V SYS voltage thresh. */
	[PCF50633_REG_BVMCTL]	= 0x02,	/* 2.80V BAT voltage thresh. */

	[PCF50633_REG_STBYCTL1]	= 0x00,
	[PCF50633_REG_STBYCTL2]	= 0x00,

	[PCF50633_REG_DEBPF1]	= 0xff,
	[PCF50633_REG_DEBPF2]	= 0xff,
	[PCF50633_REG_DEBPF2]	= 0x3f,

	[PCF50633_REG_AUTOOUT]	= 0x6b,	/* 3.300V */
	[PCF50633_REG_AUTOENA]	= 0x01,	/* always on */
	[PCF50633_REG_AUTOCTL]	= 0x00, /* automatic up/down operation */
	[PCF50633_REG_AUTOMXC]	= 0x0a,	/* 400mA at startup FIXME */

	[PCF50633_REG_DOWN1OUT]	= 0x1b, /* 1.3V (0x1b * .025V + 0.625V) */
	[PCF50633_REG_DOWN1ENA] = 0x02, /* enabled if GPIO1 = HIGH */
	[PCF50633_REG_DOWN1CTL]	= 0x00, /* no DVM */
	[PCF50633_REG_DOWN1MXC]	= 0x22,	/* limit to 510mA at startup */

	[PCF50633_REG_DOWN2OUT]	= 0x2f, /* 1.8V (0x2f * .025V + 0.625V) */
	[PCF50633_REG_DOWN2ENA]	= 0x02,
	[PCF50633_REG_DOWN2CTL]	= 0x00,	/* no DVM */
	[PCF50633_REG_DOWN2MXC]	= 0x22, /* limit to 510mA at startup */

	[PCF50633_REG_MEMLDOOUT] = 0x00,
	[PCF50633_REG_MEMLDOENA] = 0x00,

	[PCF50633_REG_LEDOUT]	= 0x2f,	/* full backlight power */
	[PCF50633_REG_LEDENA]	= 0x00,	/* disabled */
	[PCF50633_REG_LEDCTL]	= 0x05, /* ovp enabled, ocp 500mA */
	[PCF50633_REG_LEDDIM]	= 0x20,	/* dimming curve */

	[PCF50633_REG_LDO1OUT]	= 0x18,	/* 3.3V (24 * 0.1V + 0.9V) */
	[PCF50633_REG_LDO1ENA]	= 0x00,	/* GSENSOR_3V3, enable later */

	[PCF50633_REG_LDO2OUT]	= 0x18,	/* 3.3V (24 * 0.1V + 0.9V) */
	[PCF50633_REG_LDO2ENA]	= 0x00, /* CODEC_3V3, enable later */

	[PCF50633_REG_LDO3OUT]	= 0x15,
	[PCF50633_REG_LDO3ENA]	= 0x02,

	[PCF50633_REG_LDO4ENA]	= 0x00,

	[PCF50633_REG_LDO5OUT]	= 0x15, /* 3.0V (21 * 0.1V + 0.9V) */
	[PCF50633_REG_LDO5ENA]	= 0x00, /* RF_3V, enable later  */

	[PCF50633_REG_LDO6OUT]	= 0x15,	/* 3.0V (21 * 0.1V + 0.9V) */
	[PCF50633_REG_LDO6ENA]	= 0x00,	/* LCM_3V, enable later */

	[PCF50633_REG_HCLDOOUT]	= 0x18,	/* 3.3V (24 * 0.1V + 0.9V) */
	[PCF50633_REG_HCLDOENA]	= 0x00, /* off by default*/

	[PCF50633_REG_DCDCPFM]	= 0x00, /* off by default*/

	[PCF50633_REG_MBCC1]	= 0xe6,
	[PCF50633_REG_MBCC2]	= 0x28,	/* Vbatconid=2.7V, Vmax=4.20V */
	[PCF50633_REG_MBCC3]	= 0x19,	/* 25/255 == 98mA pre-charge */
	[PCF50633_REG_MBCC4]	= 0xff, /* 255/255 == 1A adapter fast */
	[PCF50633_REG_MBCC5]	= 0x19,	/* 25/255 == 98mA soft-start usb fast */
	[PCF50633_REG_MBCC6]	= 0x00, /* cutoff current 1/32 * Ichg */
	[PCF50633_REG_MBCC7]	= 0x00,	/* 1.6A max bat curr, USB 100mA */
	[PCF50633_REG_MBCC8]	= 0x00,

	[PCF50633_REG_BBCCTL]	= 0x19,	/* 3V, 200uA, on */
};

static const unsigned char regs_invalid[] = {
	PCF50633_REG_VERSION,
	PCF50633_REG_VARIANT,
	PCF50633_REG_OOCSHDWN,
	PCF50633_REG_INT1,
	PCF50633_REG_INT2,
	PCF50633_REG_INT3,
	PCF50633_REG_INT4,
	PCF50633_REG_INT5,
	PCF50633_REG_OOCSTAT,
	0x2c,
	PCF50633_REG_DCDCSTAT,
	PCF50633_REG_LDOSTAT,
	PCF50633_REG_MBCS1,
	PCF50633_REG_MBCS2,
	PCF50633_REG_MBCS3,
	PCF50633_REG_ALMDATA,
	0x51,
	/* 0x55 ... 0x6e: don't write */
	/* 0x6f ... 0x83: reserved */
};
#define PCF50633_LAST_REG	0x55

static int reg_is_invalid(unsigned char reg)
{
	int i;

	/* all registers above 0x55 (ADCS1) except 0x84 */
	if (reg == PCF50633_REG_DCDCPFM)
		return 0;
	if (reg >= 0x55)
		return 1;

	for (i = 0; i < ARRAY_SIZE(regs_invalid); i++) {
		if (regs_invalid[i] > reg)
			return 0;
		if (regs_invalid[i] == reg)
			return 1;
	}

	return 0;
}

static void pcf50633_reg_write(unsigned char reg, unsigned char val)
{
	int ret;

	if (ret = i2c_write(PCF50633_I2C_ADDR, reg, 1, &val, 1))
		printf("i2c write error %d\n", ret);
}

static unsigned char pcf50633_reg_read(unsigned char reg)
{
	unsigned char tmp;
	i2c_read(PCF50633_I2C_ADDR, reg, 1, &tmp, 1);
	return tmp;
}

static void pcf50633_reg_set_bit_mask(unsigned char reg, unsigned char mask, unsigned char val)
{
	unsigned char tmp;

	tmp = pcf50633_reg_read(reg);
	pcf50633_reg_write(reg, (val & mask) | (tmp & ~mask));
}

static void pcf50633_reg_clear_bits(unsigned char reg, unsigned char bits)
{
	unsigned char tmp;

	tmp = pcf50633_reg_read(reg);
	pcf50633_reg_write(reg, (tmp & ~bits));
}

static void pcf50633_init() {
	int i;

	i2c_init(400000, 0x7f);
	/*for (i = 0; i < PCF50633_LAST_REG; i++) {
		if (reg_is_invalid(i))
			continue;
		printf("init power reg %x.\n", i);
		pcf50633_reg_write(i, pcf50633_initial_regs[i]);
	}*/
}

void power_init() {
	pcf50633_init();
	pcf50633_reg_write(PCF50633_REG_LDO6ENA, 1);
	pcf50633_reg_write(PCF50633_REG_LEDENA, 1);
	pcf50633_reg_write(PCF50633_REG_LEDOUT, 0x3f);
}
