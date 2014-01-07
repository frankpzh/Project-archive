
.386p


_TEXT	SEGMENT PUBLIC DWORD 'CODE'
ASSUME  DS:FLAT, ES:FLAT, FS:NOTHING, GS:NOTHING, SS:NOTHING

Entry	macro name, id
	public	_Nt&name
_Nt&name:
	mov eax, id
	call _SystemCallStub
	ret
	endm

	public _SystemCallStub
_SystemCallStub:
	mov	edx, esp
	db 0fH, 34H

Entry	TestSyscall,		128H
Entry	AllocEventHandler,	129H
Entry	AddEventHandler,	12AH
Entry	RemoveEventHandler,	12BH

_TEXT   ends
        end
