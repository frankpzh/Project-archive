#include <lcm.h>
#include <glamo.h>
#include <power.h>
#include <stdio.h>

unsigned int main() {
	int i;
	unsigned char *buf = (unsigned char *)GLAMO_FB_BASE;

	glamo_init();
	lcm_init();
	power_init();

	for (i = 0; i < 614400; i++)
		buf[i] = 0xff & i;

	while (1);
}
