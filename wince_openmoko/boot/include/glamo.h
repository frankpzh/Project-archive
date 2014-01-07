#ifndef __GLAMO_H__
#define __GLAMO_H__

#define GLAMO_BASE		0x08000000
#define GLAMO_FB_BASE	0x08800000

void smedia3362_spi_cs(int b);
void smedia3362_spi_sda(int b);
void smedia3362_spi_scl(int b);
void smedia3362_lcm_reset(int b);
void glamo_init();

#endif
