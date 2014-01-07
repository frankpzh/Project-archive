#include <string.h>
#include "hdk.h"
#include "kernfunc.inc"

EXPORT void EventHandler(void *Arg) {
	char *ImageFileName = (char *)Arg;
	char SafeName[16];

	strncpy(SafeName, ImageFileName, 16);
	SafeName[15] = '\0';
	DbgPrint("Create Process: %s\n", SafeName);
}
