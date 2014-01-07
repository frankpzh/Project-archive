#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <linux/mii.h>
#include <linux/sockios.h>
#include <net/if.h>
#include <net/ethernet.h>
#include <sys/ioctl.h>

#define ROBO_PHY_ADDR		0x1E	/* RoboSwitch PHY address */

/* MII access registers */
#define ROBO_MII_PAGE		0x10	/* MII page register */
#define ROBO_MII_ADDR		0x11	/* MII address register */
#define ROBO_MII_DATA_OFFSET	0x18	/* Start of MII data registers */

#define ROBO_MII_PAGE_ENABLE	0x01	/* MII page op code */
#define ROBO_MII_ADDR_WRITE	0x01	/* MII address write op code */
#define ROBO_MII_ADDR_READ	0x02	/* MII address read op code */
#define ROBO_MII_DATA_MAX	   4	/* Consecutive MII data registers */
#define ROBO_MII_RETRY_MAX	  10	/* Read attempts before giving up */

/* Page numbers */
#define ROBO_ARLCTRL_PAGE	0x04	/* ARL control page */
#define ROBO_VLAN_PAGE		0x34	/* VLAN page */

/* ARL control page registers */
#define ROBO_ARLCTRL_CONF	0x00	/* ARL configuration register */
#define ROBO_ARLCTRL_ADDR_1	0x10	/* Multiport address 1 */
#define ROBO_ARLCTRL_VEC_1	0x16	/* Multiport vector 1 */
#define ROBO_ARLCTRL_ADDR_2	0x20	/* Multiport address 2 */
#define ROBO_ARLCTRL_VEC_2	0x26	/* Multiport vector 2 */

/* VLAN page registers */
#define ROBO_VLAN_ACCESS	0x06	/* VLAN table Access register */
#define ROBO_VLAN_READ		0x0C	/* VLAN read register */

#define WPA_GET_BE16(a) ((__u16) (((a)[0] << 8) | (a)[1]))

static const __u8 pae_group_addr[ETH_ALEN] =
{ 0x01, 0x80, 0xc2, 0x00, 0x00, 0x03 };

struct wpa_driver_roboswitch_data {
	char ifname[IFNAMSIZ + 1];
	struct ifreq ifr;
	int fd;
	__u16 ports;
} drv;

/* Copied from the kernel-only part of mii.h. */
struct mii_ioctl_data *if_mii(struct ifreq *rq)
{
	return (struct mii_ioctl_data *) &rq->ifr_ifru;
}

__u16 wpa_driver_roboswitch_mdio_read(__u8 reg)
{
	struct mii_ioctl_data *mii = if_mii(&drv.ifr);

	mii->phy_id = ROBO_PHY_ADDR;
	mii->reg_num = reg;

	if (ioctl(drv.fd, SIOCGMIIREG, &drv.ifr) < 0) {
		perror("ioctl[SIOCGMIIREG]");
		return 0x00;
	}
	return mii->val_out;
}

void wpa_driver_roboswitch_mdio_write(__u8 reg, __u16 val)
{
	struct mii_ioctl_data *mii = if_mii(&drv.ifr);

	mii->phy_id = ROBO_PHY_ADDR;
	mii->reg_num = reg;
	mii->val_in = val;

	if (ioctl(drv.fd, SIOCSMIIREG, &drv.ifr) < 0) {
		perror("ioctl[SIOCSMIIREG");
	}
}

int wpa_driver_roboswitch_reg(__u8 page, __u8 reg, __u8 op)
{
	int i;

	/* set page number */
	wpa_driver_roboswitch_mdio_write(ROBO_MII_PAGE,
					 (page << 8) | ROBO_MII_PAGE_ENABLE);
	/* set register address */
	wpa_driver_roboswitch_mdio_write(ROBO_MII_ADDR, (reg << 8) | op);

	/* check if operation completed */
	for (i = 0; i < ROBO_MII_RETRY_MAX; ++i) {
		if ((wpa_driver_roboswitch_mdio_read(ROBO_MII_ADDR) & 3) ==
		    0) {
			return 0;
		}
	}
	/* timeout */
	return -1;
}


int wpa_driver_roboswitch_read(__u8 page, __u8 reg, __u16 *val, int len)
{
	int i;

	if (len > ROBO_MII_DATA_MAX ||
	    wpa_driver_roboswitch_reg(page, reg, ROBO_MII_ADDR_READ) < 0) {
		return -1;
	}
	for (i = 0; i < len; ++i) {
		val[i] = wpa_driver_roboswitch_mdio_read(ROBO_MII_DATA_OFFSET + i);
	}
	return 0;
}


int wpa_driver_roboswitch_write(__u8 page, __u8 reg, __u16 *val, int len)
{
	int i;

	if (len > ROBO_MII_DATA_MAX) return -1;
	for (i = 0; i < len; ++i) {
		wpa_driver_roboswitch_mdio_write(ROBO_MII_DATA_OFFSET + i,
						 val[i]);
	}
	return wpa_driver_roboswitch_reg(page, reg, ROBO_MII_ADDR_WRITE);
}

int wpa_driver_roboswitch_join(const __u8 *addr)
{
	int i;
	__u16 read, zero = 0;
	/* For reasons of simplicity we assume ETH_ALEN is even. */
	__u16 addr_word[ETH_ALEN/2];
	/* RoboSwitch uses 16-bit Big Endian addresses.			*/
	/* The ordering of the words is reversed in the MII registers.	*/
	for (i = 0; i < ETH_ALEN; i += 2) {
		addr_word[(ETH_ALEN - i) / 2 - 1] = WPA_GET_BE16(addr + i);
	}

	/* check if multiport addresses are not yet enabled */
	if (wpa_driver_roboswitch_read(ROBO_ARLCTRL_PAGE,
				       ROBO_ARLCTRL_CONF, &read, 1) < 0) {
		return -1;
	}
	if (!(read & (1 << 4))){
		read |= 1 << 4;
		wpa_driver_roboswitch_write(ROBO_ARLCTRL_PAGE,
					    ROBO_ARLCTRL_ADDR_1, addr_word, 3);
		wpa_driver_roboswitch_write(ROBO_ARLCTRL_PAGE,
					    ROBO_ARLCTRL_VEC_1, &drv.ports, 1);
		wpa_driver_roboswitch_write(ROBO_ARLCTRL_PAGE,
					    ROBO_ARLCTRL_VEC_2, &zero, 1);
		wpa_driver_roboswitch_write(ROBO_ARLCTRL_PAGE,
					    ROBO_ARLCTRL_CONF, &read, 1);
		return 0;
	}
	/* check if multiport address 1 is free */
	wpa_driver_roboswitch_read(ROBO_ARLCTRL_PAGE, ROBO_ARLCTRL_VEC_1,
				   &read, 1);
	if (read == 0) {
		wpa_driver_roboswitch_write(ROBO_ARLCTRL_PAGE,
					    ROBO_ARLCTRL_ADDR_1, addr_word, 3);
		wpa_driver_roboswitch_write(ROBO_ARLCTRL_PAGE,
					    ROBO_ARLCTRL_VEC_1, &drv.ports, 1);
		return 0;
	}
	/* check if multiport address 2 is free */
	wpa_driver_roboswitch_read(ROBO_ARLCTRL_PAGE, ROBO_ARLCTRL_VEC_2,
				   &read, 1);
	if (read == 0) {
		wpa_driver_roboswitch_write(ROBO_ARLCTRL_PAGE,
					    ROBO_ARLCTRL_ADDR_2, addr_word, 3);
		wpa_driver_roboswitch_write(ROBO_ARLCTRL_PAGE,
					    ROBO_ARLCTRL_VEC_2, &drv.ports, 1);
		return 0;
	}
	/* out of free multiport addresses */
	return -1;
}


int wpa_driver_roboswitch_leave(const __u8 *addr)
{
	int i;
	__u8 mport[4] = { ROBO_ARLCTRL_VEC_1, ROBO_ARLCTRL_ADDR_1,
			ROBO_ARLCTRL_VEC_2, ROBO_ARLCTRL_ADDR_2 };
	__u16 read[3], zero = 0;
	/* same as at join */
	__u16 addr_word[ETH_ALEN/2];
	for (i = 0; i < ETH_ALEN; i += 2) {
		addr_word[(ETH_ALEN - i) / 2 - 1] = WPA_GET_BE16(addr + i);
	}

	/* find our address/vector pair */
	for (i = 0; i < 4; i += 2) {
		wpa_driver_roboswitch_read(ROBO_ARLCTRL_PAGE, mport[i],
					   read, 1);
		if (read[0] == drv.ports) {
			wpa_driver_roboswitch_read(ROBO_ARLCTRL_PAGE,
						   mport[i + 1], read, 3);
			if (memcmp(read, addr_word, 6) == 0) break;
		}
	}
	/* check if we found our address/vector pair and deactivate it */
	if (i == 4) return -1;
	wpa_driver_roboswitch_write(ROBO_ARLCTRL_PAGE, mport[i], &zero, 1);

	/* leave the multiport registers in a sane state */
	wpa_driver_roboswitch_read(ROBO_ARLCTRL_PAGE, ROBO_ARLCTRL_VEC_1,
				   read, 1);
	if (read[0] == 0) {
		wpa_driver_roboswitch_read(ROBO_ARLCTRL_PAGE,
					   ROBO_ARLCTRL_VEC_2, read, 1);
		if (read[0] == 0) {
			wpa_driver_roboswitch_read(ROBO_ARLCTRL_PAGE,
						   ROBO_ARLCTRL_CONF, read, 1);
			read[0] &= ~(1 << 4);
			wpa_driver_roboswitch_write(ROBO_ARLCTRL_PAGE,
						    ROBO_ARLCTRL_CONF, read, 1);
		} else {
			wpa_driver_roboswitch_read(ROBO_ARLCTRL_PAGE,
						   ROBO_ARLCTRL_ADDR_2, read,
						   3);
			wpa_driver_roboswitch_write(ROBO_ARLCTRL_PAGE,
						    ROBO_ARLCTRL_ADDR_1, read,
						    3);
			wpa_driver_roboswitch_read(ROBO_ARLCTRL_PAGE,
						   ROBO_ARLCTRL_VEC_2, read, 1);
			wpa_driver_roboswitch_write(ROBO_ARLCTRL_PAGE,
						    ROBO_ARLCTRL_VEC_1, read,
						    1);
			wpa_driver_roboswitch_write(ROBO_ARLCTRL_PAGE,
						    ROBO_ARLCTRL_VEC_2, &zero,
						    1);
		}
	}
	return 0;
}


void wpa_driver_roboswitch_work(const char *ifname, int is_add)
{
	int len = -1, sep = -1;
	__u16 vlan = 0, vlan_read[2];

	while (ifname[++len]) if (ifname[len] == '.') sep = len;
	if (sep < 0 || sep >= len - 1) {
		fprintf(stderr, "%s: No <interface>.<vlan> pair in "
				"interfacename %s\n", __func__, ifname);
		return;
	}
	if (sep > IFNAMSIZ) {
		fprintf(stderr, "%s: Interfacename %s is too long\n",
			   __func__, ifname);
		return;
	}

	memcpy(drv.ifname, ifname, sep);
	drv.ifname[sep] = '\0';
	while (++sep < len) {
		if (ifname[sep] < '0' || ifname[sep] > '9') {
			fprintf(stderr, "%s: Invalid vlan specification "
					"in interfacename %s\n", __func__, ifname);
			return;
		}
		vlan *= 10;
		vlan += ifname[sep] - '0';
		if (vlan > 255) {
			fprintf(stderr, "%s: VLAN out of range in "
					"interfacename %s\n", __func__, ifname);
			return;
		}
	}

	if ((drv.fd = socket(PF_INET, SOCK_DGRAM, 0)) < 0) {
		fprintf(stderr, "%s: Unable to create socket\n", __func__);
		return;
	}

	memset(&drv.ifr, 0, sizeof(drv.ifr));
	strncpy(drv.ifr.ifr_name, drv.ifname, IFNAMSIZ);
	if (ioctl(drv.fd, SIOCGMIIPHY, &drv.ifr) < 0) {
		perror("ioctl[SIOCGMIIPHY]");
		goto ret;
	}
	if (if_mii(&drv.ifr)->phy_id != ROBO_PHY_ADDR) {
		fprintf(stderr, "%s: Invalid phy address (not a RoboSwitch?)\n", __func__);
		goto ret;
	}

	vlan |= 1 << 13;
	/* The BCM5365 uses a different register and is not accounted for. */
	wpa_driver_roboswitch_write(ROBO_VLAN_PAGE, ROBO_VLAN_ACCESS,
				    &vlan, 1);
	wpa_driver_roboswitch_read(ROBO_VLAN_PAGE, ROBO_VLAN_READ,
				   vlan_read, 2);
	if (!(vlan_read[1] & (1 << 4))) {
		fprintf(stderr, "%s: Could not get port information for "
				"VLAN %d\n", __func__, vlan & ~(1 << 13));
		goto ret;
	}
	drv.ports = vlan_read[0] & 0x001F;
	/* add the MII port */
	drv.ports |= 1 << 8;
	if (is_add) {
		if (wpa_driver_roboswitch_join(pae_group_addr) < 0)
			fprintf(stderr, "%s: Unable to join PAE group\n", __func__);
		else
			fprintf(stderr, "%s: Added PAE group address to "
					"RoboSwitch ARL\n", __func__);
	}
	else {
		if (wpa_driver_roboswitch_leave(pae_group_addr) < 0)
			fprintf(stderr, "%s: Unable to leave PAE group",
				__func__);
		else
			fprintf(stderr, "%s: Removed PAE group address to "
					"RoboSwitch ARL\n", __func__);
	}
ret:
	close(drv.fd);
}

void usage() {
	fprintf(stderr, "Usage: mii_switch on|off <interface>\n");
	exit(1);
}

int main(int argc, char ** argv) {
	if (argc != 3)
		usage();
	if (!strcmp(argv[1], "on"))
		wpa_driver_roboswitch_work(argv[2], 1);
	else if (!strcmp(argv[1], "off"))
		wpa_driver_roboswitch_work(argv[2], 0);
	else
		usage();
	return 0;
}

