#ifndef _HDK_
#define _HDK_

#define EXPORT __declspec(dllexport)
#pragma warning(disable:4047)

extern unsigned int (*DbgPrint)(char *Format, ...);

#endif
