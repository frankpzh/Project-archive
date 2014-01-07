#include <io.h>
#include <lcm.h>
#include <glamo.h>

enum jbt_register {
	JBT_REG_SLEEP_IN		= 0x10,
	JBT_REG_SLEEP_OUT		= 0x11,

	JBT_REG_DISPLAY_OFF		= 0x28,
	JBT_REG_DISPLAY_ON		= 0x29,

	JBT_REG_RGB_FORMAT		= 0x3a,
	JBT_REG_QUAD_RATE		= 0x3b,

	JBT_REG_POWER_ON_OFF		= 0xb0,
	JBT_REG_BOOSTER_OP		= 0xb1,
	JBT_REG_BOOSTER_MODE		= 0xb2,
	JBT_REG_BOOSTER_FREQ		= 0xb3,
	JBT_REG_OPAMP_SYSCLK		= 0xb4,
	JBT_REG_VSC_VOLTAGE		= 0xb5,
	JBT_REG_VCOM_VOLTAGE		= 0xb6,
	JBT_REG_EXT_DISPL		= 0xb7,
	JBT_REG_OUTPUT_CONTROL		= 0xb8,
	JBT_REG_DCCLK_DCEV		= 0xb9,
	JBT_REG_DISPLAY_MODE1		= 0xba,
	JBT_REG_DISPLAY_MODE2		= 0xbb,
	JBT_REG_DISPLAY_MODE		= 0xbc,
	JBT_REG_ASW_SLEW		= 0xbd,
	JBT_REG_DUMMY_DISPLAY		= 0xbe,
	JBT_REG_DRIVE_SYSTEM		= 0xbf,

	JBT_REG_SLEEP_OUT_FR_A		= 0xc0,
	JBT_REG_SLEEP_OUT_FR_B		= 0xc1,
	JBT_REG_SLEEP_OUT_FR_C		= 0xc2,
	JBT_REG_SLEEP_IN_LCCNT_D	= 0xc3,
	JBT_REG_SLEEP_IN_LCCNT_E	= 0xc4,
	JBT_REG_SLEEP_IN_LCCNT_F	= 0xc5,
	JBT_REG_SLEEP_IN_LCCNT_G	= 0xc6,

	JBT_REG_GAMMA1_FINE_1		= 0xc7,
	JBT_REG_GAMMA1_FINE_2		= 0xc8,
	JBT_REG_GAMMA1_INCLINATION	= 0xc9,
	JBT_REG_GAMMA1_BLUE_OFFSET	= 0xca,

	JBT_REG_BLANK_CONTROL		= 0xcf,
	JBT_REG_BLANK_TH_TV		= 0xd0,
	JBT_REG_CKV_ON_OFF		= 0xd1,
	JBT_REG_CKV_1_2			= 0xd2,
	JBT_REG_OEV_TIMING		= 0xd3,
	JBT_REG_ASW_TIMING_1		= 0xd4,
	JBT_REG_ASW_TIMING_2		= 0xd5,

	JBT_REG_HCLOCK_VGA		= 0xec,
	JBT_REG_HCLOCK_QVGA		= 0xed,

};

#define SPI_CS(b)   smedia3362_spi_cs(b)
#define SPI_SDA(b)  smedia3362_spi_sda(b)
#define SPI_SCL(b)  smedia3362_spi_scl(b)

/* 150uS minimum clock cycle, we have two of this plus our other
 * instructions */
#define SPI_DELAY	DELAY(600)	/* 200uS */

static int jbt_spi_xfer(int wordnum, int bitlen, unsigned short *dout)
{
	unsigned short tmpdout = 0;
	int   i, j;

	SPI_CS(0);

	for (i = 0; i < wordnum; i ++) {
		tmpdout = dout[i];

		for (j = 0; j < bitlen; j++) {
			SPI_SCL(0);
			if (tmpdout & (1 << bitlen-1))
				SPI_SDA(1);
			else
				SPI_SDA(0);
			SPI_DELAY;
			SPI_SCL(1);
			SPI_DELAY;
			tmpdout <<= 1;
		}
	}
	SPI_CS(1);

	return 0;
}

#define JBT_COMMAND	0x000
#define JBT_DATA	0x100

static unsigned short tx_buf[4];

static int jbt_reg_write_nodata(unsigned char reg)
{
	int rc;

	tx_buf[0] = JBT_COMMAND | reg;
	rc = jbt_spi_xfer(1, 9, tx_buf);

	return rc;
}


static int jbt_reg_write(unsigned char reg, unsigned char data)
{
	int rc;

	tx_buf[0] = JBT_COMMAND | reg;
	tx_buf[1] = JBT_DATA | data;
	rc = jbt_spi_xfer(2, 9, tx_buf);

	return rc;
}

static int jbt_reg_write16(unsigned char reg, unsigned short data)
{
	int rc;

	tx_buf[0] = JBT_COMMAND | reg;
	tx_buf[1] = JBT_DATA | (data >> 8);
	tx_buf[2] = JBT_DATA | (data & 0xff);
	rc = jbt_spi_xfer(3, 9, tx_buf);

	return rc;
}

static int jbt_init_regs()
{
	int rc;

	rc = jbt_reg_write(JBT_REG_DISPLAY_MODE1, 0x01);
	rc |= jbt_reg_write(JBT_REG_DISPLAY_MODE2, 0x00);
	rc |= jbt_reg_write(JBT_REG_RGB_FORMAT, 0x60);
	rc |= jbt_reg_write(JBT_REG_DRIVE_SYSTEM, 0x10);
	rc |= jbt_reg_write(JBT_REG_BOOSTER_OP, 0x56);
	rc |= jbt_reg_write(JBT_REG_BOOSTER_MODE, 0x33);
	rc |= jbt_reg_write(JBT_REG_BOOSTER_FREQ, 0x11);
	rc |= jbt_reg_write(JBT_REG_BOOSTER_FREQ, 0x11);
	rc |= jbt_reg_write(JBT_REG_OPAMP_SYSCLK, 0x02);
	rc |= jbt_reg_write(JBT_REG_VSC_VOLTAGE, 0x2b);
	rc |= jbt_reg_write(JBT_REG_VCOM_VOLTAGE, 0x40);
	rc |= jbt_reg_write(JBT_REG_EXT_DISPL, 0x03);
	rc |= jbt_reg_write(JBT_REG_DCCLK_DCEV, 0x04);
	/*
	 * default of 0x02 in JBT_REG_ASW_SLEW responsible for 72Hz requirement
	 * to avoid red / blue flicker
	 */
	rc |= jbt_reg_write(JBT_REG_ASW_SLEW, 0x04);
	rc |= jbt_reg_write(JBT_REG_DUMMY_DISPLAY, 0x00);

	rc |= jbt_reg_write(JBT_REG_SLEEP_OUT_FR_A, 0x11);
	rc |= jbt_reg_write(JBT_REG_SLEEP_OUT_FR_B, 0x11);
	rc |= jbt_reg_write(JBT_REG_SLEEP_OUT_FR_C, 0x11);
	rc |= jbt_reg_write16(JBT_REG_SLEEP_IN_LCCNT_D, 0x2040);
	rc |= jbt_reg_write16(JBT_REG_SLEEP_IN_LCCNT_E, 0x60c0);
	rc |= jbt_reg_write16(JBT_REG_SLEEP_IN_LCCNT_F, 0x1020);
	rc |= jbt_reg_write16(JBT_REG_SLEEP_IN_LCCNT_G, 0x60c0);

	rc |= jbt_reg_write16(JBT_REG_GAMMA1_FINE_1, 0x5533);
	rc |= jbt_reg_write(JBT_REG_GAMMA1_FINE_2, 0x00);
	rc |= jbt_reg_write(JBT_REG_GAMMA1_INCLINATION, 0x00);
	rc |= jbt_reg_write(JBT_REG_GAMMA1_BLUE_OFFSET, 0x00);
	rc |= jbt_reg_write(JBT_REG_GAMMA1_BLUE_OFFSET, 0x00);

	rc |= jbt_reg_write16(JBT_REG_HCLOCK_VGA, 0x1f0);
	rc |= jbt_reg_write(JBT_REG_BLANK_CONTROL, 0x02);
	rc |= jbt_reg_write16(JBT_REG_BLANK_TH_TV, 0x0804);
	rc |= jbt_reg_write16(JBT_REG_BLANK_TH_TV, 0x0804);

	rc |= jbt_reg_write(JBT_REG_CKV_ON_OFF, 0x01);
	rc |= jbt_reg_write16(JBT_REG_CKV_1_2, 0x0000);

	rc |= jbt_reg_write16(JBT_REG_OEV_TIMING, 0x0d0e);
	rc |= jbt_reg_write16(JBT_REG_ASW_TIMING_1, 0x11a4);
	rc |= jbt_reg_write(JBT_REG_ASW_TIMING_2, 0x0e);

	return rc;
}

static int standby_to_sleep()
{
	int rc;

	/* three times command zero */
	rc = jbt_reg_write_nodata(0x00);
	DELAY(3000);
	rc = jbt_reg_write_nodata(0x00);
	DELAY(3000);
	rc = jbt_reg_write_nodata(0x00);
	DELAY(3000);

	/* deep standby out */
	rc |= jbt_reg_write(JBT_REG_POWER_ON_OFF, 0x17);

	return rc;
}

static int sleep_to_normal()
{
	int rc;

	/* RGB I/F on, RAM wirte off, QVGA through, SIGCON enable */
	rc = jbt_reg_write(JBT_REG_DISPLAY_MODE, 0x80);

	/* Quad mode off */
	rc |= jbt_reg_write(JBT_REG_QUAD_RATE, 0x00);

	/* AVDD on, XVDD on */
	rc |= jbt_reg_write(JBT_REG_POWER_ON_OFF, 0x16);

	/* Output control */
	rc |= jbt_reg_write16(JBT_REG_OUTPUT_CONTROL, 0xfff9);

	/* Sleep mode off */
	rc |= jbt_reg_write_nodata(JBT_REG_SLEEP_OUT);

	/* at this point we have like 50% grey */

	/* initialize register set */
	rc |= jbt_init_regs();
	return rc;
}


int lcm_display(int on)
{
	if (on)
		return jbt_reg_write_nodata(JBT_REG_DISPLAY_ON);
	else
		return jbt_reg_write_nodata(JBT_REG_DISPLAY_OFF);
}

void lcm_init()
{
	smedia3362_lcm_reset(1);
	DELAY(180000);
	standby_to_sleep();
	sleep_to_normal();
	lcm_display(1);
}
