#ifndef _SYSCALL_
#define _SYSCALL_

#include "nt.h"

typedef enum _EVENT {
	KiSwapThreadEvent,
	PspCreateThreadEvent
	} EVENT;

typedef enum _HANDLER_ERROR {
	NO_ERROR,
	INVALID_EVENT,
	HANDLER_CONFLICT,
	BINARY_ERROR,
	NO_HANDLER
	} HANDLER_ERROR;

/*
	NtTestSyscall

	returns arg1+1
*/
extern ULONG
NtTestSyscall(
	IN ULONG arg1,
	IN ULONG arg2
	);

/*
	NtAddEventHandler
*/
extern HANDLER_ERROR
NtAddEventHandler(
	IN EVENT EventId,
	IN PVOID HandlerAddr,
	IN PVOID HandlerEntry
	);

/*
	NtAllocEventHandler
*/
extern HANDLER_ERROR
NtAllocEventHandler(
	IN EVENT EventId,
	IN ULONG CodeAlignment,
	IN SIZE_T CodeSizeInBytes,
	OUT PPVOID HandlerBase
	);

/*
	NtRemoveEventHandler
*/
extern HANDLER_ERROR
NtRemoveEventHandler(
	IN EVENT EventId
	);

#endif
