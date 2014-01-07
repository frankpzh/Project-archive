#include <stdio.h>
#include "injector.h"

int main(int argc, char *argv[]) {
	if (argc == 2) {
		printf("NtRemoveEventHandler(%d)\nReturn code: %d\n", argv[1][0] - '0',
			NtRemoveEventHandler(argv[1][0] - '0'));
	}
	else if (argc == 3) {
		printf("InjectDllFile(%s, %d)\nReturn code: %d\n", argv[1], argv[2][0] - '0',
			InjectDllFile(argv[1], argv[2][0] - '0'));
	}
	else {
		printf("Invalid Usage.\n");
		return 1;
	}		
	return 0;
}
