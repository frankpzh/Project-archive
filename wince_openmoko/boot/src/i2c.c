#include <i2c.h>
#include <io.h>

#define	I2C_WRITE	0
#define I2C_READ	1

#define I2C_OK		0
#define I2C_NOK		1
#define I2C_NACK	2
#define I2C_NOK_LA	3		/* Lost arbitration */
#define I2C_NOK_TOUT	4		/* time out */

#define I2CSTAT_BSY	0x20		/* Busy bit */
#define I2CSTAT_NACK	0x01		/* Nack bit */
#define I2CCON_IRPND	0x10		/* Interrupt pending bit */
#define I2C_MODE_MT	0xC0		/* Master Transmit Mode */
#define I2C_MODE_MR	0x80		/* Master Receive Mode */
#define I2C_START_STOP	0x20		/* START / STOP */
#define I2C_TXRX_ENA	0x10		/* I2C Tx/Rx enable */

#define I2C_TIMEOUT 1			/* 1 second */


static int GetI2CSDA(void)
{
	return GPIO_READ(E, 15);
}


static void SetI2CSCL(int x)
{
	GPIO_WRITE(E, 14, x & 1);
}


static int WaitForXfer (void)
{
	volatile int i, status;

	i = I2C_TIMEOUT * 10000;
	status = IO_READ(IICCON);
	while ((i > 0) && !(status & I2CCON_IRPND)) {
		DELAY(300);
		status = IO_READ(IICCON);
		i--;
	}

	return (status & I2CCON_IRPND) ? I2C_OK : I2C_NOK_TOUT;
}

static int IsACK (void)
{
	return !(IO_READ(IICSTAT) & I2CSTAT_NACK);
}

static void ReadWriteByte (void)
{
	IO_WRITE(IICCON, IO_READ(IICCON) & ~I2CCON_IRPND);
}

void i2c_init (int speed, int slaveadd)
{
	unsigned int freq, pres = 16, divs;
	volatile int i, status;

	GPIO_SET(E, 14, GPIO_FUNC);
	GPIO_SET(E, 15, GPIO_FUNC);

	/* wait for some time to give previous transfer a chance to finish */

	i = I2C_TIMEOUT * 1000;
	status = IO_READ(IICSTAT);
	while ((i > 0) && (status & I2CSTAT_BSY)) {
		DELAY(3000);
		status = IO_READ(IICSTAT);
		i--;
	}

	if ((status & I2CSTAT_BSY) || GetI2CSDA() == 0) {
		/* set I2CSDA and I2CSCL (GPE15, GPE14) to GPIO */
		GPIO_SET(E, 14, GPIO_OUTPUT);
		GPIO_SET(E, 15, GPIO_INPUT);

		/* toggle I2CSCL until bus idle */
		SetI2CSCL(0);
		DELAY(3000);
		i = 10;
		while ((i > 0) && (GetI2CSDA() != 1)) {
			SetI2CSCL(1);
			DELAY(3000);
			SetI2CSCL(0);
			DELAY(3000);
			i--;
		}
		SetI2CSCL(1);
		DELAY(3000);

		/* restore pin functions */
		GPIO_SET(E, 14, GPIO_FUNC);
		GPIO_SET(E, 15, GPIO_FUNC);
	}

	/* calculate prescaler and divisor values */
	freq = 50000000;
	if ((freq / pres / (16 + 1)) > speed)
		/* set prescaler to 512 */
		pres = 512;

	divs = 0;
	while ((div(div(freq, pres), divs + 1)) > speed)
		divs++;

	/* set prescaler, divisor according to freq, also set
	 * ACKGEN, IRQ */
	IO_WRITE(IICCON, (divs & 0x0F) | 0xA0 | ((pres == 512) ? 0x40 : 0));

	/* init to SLAVE REVEIVE and set slaveaddr */
	IO_WRITE(IICSTAT, 0);
	IO_WRITE(IICADD, slaveadd);
	/* program Master Transmit (and implicit STOP) */
	IO_WRITE(IICSTAT, I2C_MODE_MT | I2C_TXRX_ENA);

}

/*
 * cmd_type is 0 for write, 1 for read.
 *
 * addr_len can take any value from 0-255, it is only limited
 * by the char, we could make it larger if needed. If it is
 * 0 we skip the address write cycle.
 */
static
int i2c_transfer (unsigned char cmd_type,
		  unsigned char chip,
		  unsigned char addr[],
		  unsigned char addr_len,
		  unsigned char data[], unsigned short data_len)
{
	volatile int i, status, result;

	if (data == 0 || data_len == 0) {
		/*Don't support data transfer of no length or to address 0 */
		printf ("i2c_transfer: bad call\n");
		return I2C_NOK;
	}

	/* Check I2C bus idle */
	i = I2C_TIMEOUT * 1000;
	status = IO_READ(IICSTAT);
	while ((i > 0) && (status & I2CSTAT_BSY)) {
		DELAY(3000);
		status = IO_READ(IICSTAT);
		i--;
	}

	if (status & I2CSTAT_BSY)
		return I2C_NOK_TOUT;

	IO_WRITE(IICCON, IO_READ(IICCON) | 0x80);
	result = I2C_OK;

	switch (cmd_type) {
	case I2C_WRITE:
		if (addr && addr_len) {
			IO_WRITE(IICDS, chip);
			/* send START */
			IO_WRITE(IICSTAT, I2C_MODE_MT | I2C_TXRX_ENA | I2C_START_STOP);
			i = 0;
			while ((i < addr_len) && (result == I2C_OK)) {
				result = WaitForXfer ();
				IO_WRITE(IICDS, addr[i]);
				ReadWriteByte ();
				i++;
			}
			i = 0;
			while ((i < data_len) && (result == I2C_OK)) {
				result = WaitForXfer ();
				IO_WRITE(IICDS, data[i]);
				ReadWriteByte ();
				i++;
			}
		} else {
			IO_WRITE(IICDS, chip);
			/* send START */
			IO_WRITE(IICSTAT, I2C_MODE_MT | I2C_TXRX_ENA | I2C_START_STOP);
			i = 0;
			while ((i < data_len) && (result = I2C_OK)) {
				result = WaitForXfer ();
				IO_WRITE(IICDS, data[i]);
				ReadWriteByte ();
				i++;
			}
		}

		if (result == I2C_OK)
			result = WaitForXfer ();

		/* send STOP */
		IO_WRITE(IICSTAT, I2C_MODE_MR | I2C_TXRX_ENA);
		ReadWriteByte ();
		break;

	case I2C_READ:
		if (addr && addr_len) {
			IO_WRITE(IICSTAT, I2C_MODE_MT | I2C_TXRX_ENA);
			IO_WRITE(IICDS, chip);
			/* send START */
			IO_WRITE(IICSTAT, IO_READ(IICSTAT) | I2C_START_STOP);
			result = WaitForXfer ();
			if (IsACK ()) {
				i = 0;
				while ((i < addr_len) && (result == I2C_OK)) {
					IO_WRITE(IICDS, addr[i]);
					ReadWriteByte ();
					result = WaitForXfer ();
					i++;
				}

				IO_WRITE(IICDS, chip);
				/* resend START */
				IO_WRITE(IICSTAT, I2C_MODE_MR | I2C_TXRX_ENA |
						I2C_START_STOP);
				ReadWriteByte ();
				result = WaitForXfer ();
				i = 0;
				while ((i < data_len) && (result == I2C_OK)) {
					/* disable ACK for final READ */
					if (i == data_len - 1)
						IO_WRITE(IICCON, IO_READ(IICCON) & ~0x80);
					ReadWriteByte ();
					result = WaitForXfer ();
					data[i] = IO_READ(IICDS);
					i++;
				}
			} else {
				result = I2C_NACK;
			}

		} else {
			IO_WRITE(IICSTAT, I2C_MODE_MR | I2C_TXRX_ENA);
			IO_WRITE(IICDS, chip);
			/* send START */
			IO_WRITE(IICSTAT, IO_READ(IICSTAT) | I2C_START_STOP);
			result = WaitForXfer ();

			if (IsACK ()) {
				i = 0;
				while ((i < data_len) && (result == I2C_OK)) {
					/* disable ACK for final READ */
					if (i == data_len - 1)
						IO_WRITE(IICCON, IO_READ(IICCON) & ~0x80);
					ReadWriteByte ();
					result = WaitForXfer ();
					data[i] = IO_READ(IICDS);
					i++;
				}
			} else {
				result = I2C_NACK;
			}
		}

		/* send STOP */
		IO_WRITE(IICSTAT, I2C_MODE_MR | I2C_TXRX_ENA);
		ReadWriteByte ();
		break;

	default:
		printf ("i2c_transfer: bad call\n");
		result = I2C_NOK;
		break;
	}

	return result;
}

int i2c_probe (unsigned char chip)
{
	unsigned char buf[1];

	buf[0] = 0;

	/*
	 * What is needed is to send the chip address and verify that the
	 * address was <ACK>ed (i.e. there was a chip at that address which
	 * drove the data line low).
	 */
	return (i2c_transfer (I2C_READ, chip << 1, 0, 0, buf, 1) != I2C_OK);
}

int i2c_read (unsigned char chip, unsigned int addr, int alen, unsigned char * buffer, int len)
{
	unsigned char xaddr[4];
	int ret;

	if (alen > 4) {
		printf ("I2C read: addr len %d not supported\n", alen);
		return 1;
	}

	if (alen > 0) {
		xaddr[0] = (addr >> 24) & 0xFF;
		xaddr[1] = (addr >> 16) & 0xFF;
		xaddr[2] = (addr >> 8) & 0xFF;
		xaddr[3] = addr & 0xFF;
	}

	if ((ret =
	     i2c_transfer (I2C_READ, chip << 1, &xaddr[4 - alen], alen,
			   buffer, len)) != 0) {
		printf ("I2c read: failed %d\n", ret);
		return 1;
	}
	return 0;
}

int i2c_write (unsigned char chip, unsigned int addr, int alen, unsigned char * buffer, int len)
{
	unsigned char xaddr[4];

	if (alen > 4) {
		printf ("I2C write: addr len %d not supported\n", alen);
		return 1;
	}

	if (alen > 0) {
		xaddr[0] = (addr >> 24) & 0xFF;
		xaddr[1] = (addr >> 16) & 0xFF;
		xaddr[2] = (addr >> 8) & 0xFF;
		xaddr[3] = addr & 0xFF;
	}
	return (i2c_transfer
		(I2C_WRITE, chip << 1, &xaddr[4 - alen], alen, buffer,
		 len) != 0);
}

