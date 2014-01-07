#include <io.h>
#include <led.h>

void led_init() {
	GPIO_SET(B, 0, GPIO_OUTPUT);
	GPIO_SET(B, 1, GPIO_OUTPUT);
	GPIO_SET(B, 2, GPIO_OUTPUT);
	GPIO_SET(B, 3, GPIO_OUTPUT);
}

int led_set(int id, int stat) {
	if (stat)
		stat = 1;
	if (id < 0 || id > 3)
		return -1;
	GPIO_WRITE(B, id, stat);
	return 0;
}

int led_get(int id) {
	if (id < 0 || id > 3)
		return -1;
	return GPIO_READ(B, id);
}
