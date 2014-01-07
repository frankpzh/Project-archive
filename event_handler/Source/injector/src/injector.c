#include<stdio.h>
#include<malloc.h>

#include "syscall.h"
#include "injector.h"
#include "pereader.h"

INJECTOR_ERROR
ReadDllFile(
	IN char *FileName,
	IN OUT PPE_FILE Pe
)
{
	FILE *File;
	
	// Open File
	if (fopen_s(&File, FileName, "rb")) {
		return INJECTOR_OPEN_FILE_ERROR;
	}

	// Get Size of File
	fseek(File, 0, SEEK_END);
	Pe->RawDataSize = ftell(File);
	fseek(File, 0, SEEK_SET);

	// Allocate Memory
	Pe->RawData = (PUCHAR)malloc(Pe->RawDataSize);
	// Read File
	fread(Pe->RawData, 1, Pe->RawDataSize, File);
	// Close File
	fclose(File);
	
	return INJECTOR_NO_ERROR;
}

INJECTOR_ERROR
InjectDllFile(
	IN char *FileName,
	IN EVENT EventId
)

/*
	Function:

		InjectDllName

	Description:

		Inject the DLL file into the kernel, make it be an event handler.

	Arguments:

		FileName - The filename of the dll.
		EventId - The event which is going to inject into.

	Return Value:
	
		INJECTOR_NO_ERROR - No error.
		INJECTOR_OPEN_FILE_ERROR - Could not open the DLL File.
		
*/

{
	PE_FILE Pe;
	PVOID HandlerEntry;
	CHAR HandlerAllocated;
	PEREADER_ERROR PeError;
	HANDLER_ERROR KernelError;
	INJECTOR_ERROR ReturnValue;

	// Initialize
	HandlerAllocated = 0;
	Pe.RawData = 0;
	Pe.LoadedData = 0;

	// Read DLL File
	ReturnValue = ReadDllFile(FileName, &Pe);
	if (ReturnValue != INJECTOR_NO_ERROR) {
		goto err;
	}
	
	// Parse File
	PeError = PeReaderParsePe(&Pe);
	if (PeError != PEREADER_NO_ERROR) {
		ReturnValue = INJECTOR_PE_PARSE_ERROR;
		goto err;
	}
	if (Pe.FileType != PETYPE_PE32_DLL) {
		ReturnValue = INJECTOR_NOT_A_DLL_ERROR;
		goto err;
	}
	PeError = PeReaderGetLoadedSize(&Pe);
	if (PeError != PEREADER_NO_ERROR) {
		ReturnValue = INJECTOR_PE_PARSE_ERROR;
		goto err;
	}

	// Allocate Memory in Kernel
	KernelError = NtAllocEventHandler(EventId, 
		Pe.Pe32Header->WindowsSpecificFields.SectionAlignment,
			Pe.LoadedDataSize, &(PVOID)Pe.LoadBaseAddress);
	if (KernelError != NO_ERROR) {
		printf("InkernelError: %d\n", KernelError);
		ReturnValue = INJECTOR_INKERNEL_ERROR;
		goto err;
	}
	HandlerAllocated = 1;

	// Load Data
	Pe.LoadedData = (PUCHAR)malloc(Pe.LoadedDataSize);
	PeError = PeReaderLoad(&Pe);
	if (PeError != PEREADER_NO_ERROR) {
		ReturnValue = INJECTOR_PE_LOAD_ERROR;
		goto err;
	}

	// Search Entry
	PeError = PeReaderSeekExportedName(&Pe, "_EventHandler@4", &HandlerEntry);
	if (PeError != PEREADER_NO_ERROR) {
		ReturnValue = INJECTOR_HANDLER_ENTRY_NOT_FOUND;
		goto err;
	}

	// Inject Code
	KernelError = NtAddEventHandler(EventId, Pe.LoadedData, HandlerEntry);
	if (KernelError != NO_ERROR) {
		printf("InkernelError: %d\n", KernelError);
		ReturnValue = INJECTOR_INKERNEL_ERROR;
		goto err;
	}

	// Free Memory
	free(Pe.LoadedData);
	free(Pe.RawData);
	
	return INJECTOR_NO_ERROR;

err:
	if (Pe.RawData) {
		free(Pe.RawData);
	}
	if (Pe.LoadedData) {
		free(Pe.LoadedData);
	}
	if (HandlerAllocated) {
		NtRemoveEventHandler(EventId);
	}
	
	return ReturnValue;
}

