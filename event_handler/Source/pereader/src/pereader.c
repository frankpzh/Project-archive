//#define PEREADER_DEBUG
#include "pereader.h"

#include <string.h>
#ifdef PEREADER_DEBUG
#include <stdio.h>
#endif

// Check the address interval [base, base + size), avoid memory leaks.
#define CHK_ADDR(base, size) \
	if (((PUCHAR)base + size) > (PeFile->RawData + PeFile->RawDataSize)) \
		return PEREADER_INVALID_PE_FORMAT

PEREADER_ERROR
PeReaderParsePe(
	IN OUT PPE_FILE PeFile
)

/*

	Function:
	
		PeReaderParsePe

	Description:

		Generate type and pointers by RawData and RawDataSize in PeFile.

	Arguments:

		PeFile - The data structure to commit.

	Return:

		The exit code.

*/

{
	ULONG *PeSignature;

	// Initialize FileType
	PeFile->FileType = PETYPE_INVALID_PE;
	PeFile->FileStat = PEFILE_NOT_PARSED;
	
	// At location 0x3c, the MS-DOS stub has the file offset to PE signature,
	// which is just in front of CoffHeader.
	PeSignature = (PULONG)(PeFile->RawData + *(PULONG)(PeFile->RawData + 0x3c));
	if (*PeSignature != 0x00004550) {
		// PE signature does not fit
		return PEREADER_INVALID_PE_FORMAT;
	}

	// CoffHeader
	PeFile->CoffHeader = (PCOFF_HEADER)(PeSignature + 1);
	CHK_ADDR(PeFile->CoffHeader, sizeof(COFF_HEADER));

	// Optional header
	PeFile->Pe32Header = (PPE32_HEADER)(PeFile->CoffHeader + 1);
	CHK_ADDR(PeFile->Pe32Header, sizeof(PE32_HEADER));

	// Section headers(section table) immediately follows the option header.
	PeFile->SectionHeaders = (PSECTION_HEADER)((PUCHAR)PeFile->Pe32Header +
		PeFile->CoffHeader->SizeOfOptionalHeader);
	CHK_ADDR(PeFile->SectionHeaders, 
		sizeof(SECTION_HEADER) * PeFile->CoffHeader->NumberOfSections);

	// Check the Magic Number of PE Header
	if (PeFile->Pe32Header->StandardFields.Magic != PE32_MAGIC &&
		PeFile->Pe32pHeader->StandardFields.Magic != PE32P_MAGIC) {
		return PEREADER_INVALID_PE_FORMAT;
	}
	
	// Determine FileType by flags.
	if (PeFile->CoffHeader->Characteristics & IMAGE_FILE_DLL) {
		PeFile->FileType = (PeFile->Pe32Header->StandardFields.Magic == PE32_MAGIC) ? 
			PETYPE_PE32_DLL: PETYPE_PE32P_DLL;
	}
	else if (PeFile->CoffHeader->Characteristics & IMAGE_FILE_EXECUTABLE_IMAGE) {
		PeFile->FileType = (PeFile->Pe32Header->StandardFields.Magic == PE32_MAGIC) ? 
			PETYPE_PE32_EXE : PETYPE_PE32P_EXE;
	}
	else {
		PeFile->FileType = PETYPE_OTHER;
	}
	PeFile->FileStat = PEFILE_NOT_LOADED;
	
	return PEREADER_NO_ERROR;
}

PEREADER_ERROR
PeReaderGetLoadedSize(
	IN OUT PPE_FILE PeFile
)

/*

	Function:
	
		PeReaderGetLoadedSize

	Description:

		Calculate the size needed to load the PE file.

	Arguments:

		PeFile - The data structure to commit.

	Return:

		The exit code.

*/

{
	int i;

	if (PeFile->FileType == PETYPE_INVALID_PE) {
		return PEREADER_INVALID_PE_FORMAT;
	}
	if (PeFile->FileStat == PEFILE_NOT_PARSED) {
		return PEREADER_PE_NOT_PARSED;
	}
	
	// Initialize
	PeFile->LoadedDataSize = 0;

	// For every section
	for (i = 0; i < PeFile->CoffHeader->NumberOfSections; i++) {
		// Ignore sections need not to load
		if (PeFile->SectionHeaders[i].VirtualSize) {
			// Get the largest address to fill data
			UPDATE_MAX(PeFile->LoadedDataSize, 
				PeFile->SectionHeaders[i].VirtualAddress + PeFile->SectionHeaders[i].VirtualSize);
		}
	}
	
	return PEREADER_NO_ERROR;
}

ULONG
PeReaderGetImageBase(
	IN PPE_FILE PeFile
)

/*

	Function:

		PeReaderGetImageBase

	Description:

		Get the ImageBase from a PE_FILE structure.

	Arguments:

		PeFile - The structure.

	Return:

		For a valid PE file, return the ImageBase;
		Otherwise, 0.

*/

{
	if (PeFile->FileType == PETYPE_INVALID_PE) {
		return 0;
	}
	if (PeFile->Pe32Header->StandardFields.Magic == PE32_MAGIC) {
		return PeFile->Pe32Header->WindowsSpecificFields.ImageBase;
	}
	if (PeFile->Pe32pHeader->StandardFields.Magic == PE32P_MAGIC) {
		return (ULONG)PeFile->Pe32pHeader->WindowsSpecificFields.ImageBase.UseThisFieldToCopy;
	}
	return 0;
}

PPE32_DATA_DIR
PeReaderGetDataDirectory(
	IN PPE_FILE PeFile,
	IN ULONG Index
)

/*

	Function:

		PeReaderGetDataDirectory

	Description:

		Get the specified DataDirectory from a PE_FILE structure.

	Arguments:

		PeFile - The structure.
		Index - The index of the DataDirectory.

	Return:

		For a valid PE file, return the pointer of the specified DataDirectory;
		Otherwise, 0.

*/

{
	if (PeFile->FileType == PETYPE_INVALID_PE) {
		return 0;
	}
	if (PeFile->Pe32Header->StandardFields.Magic == PE32_MAGIC) {
		return &SEEK_AFTER(PE32_DATA_DIR, PeFile->Pe32Header->DataDirectories, Index);
	}
	if (PeFile->Pe32pHeader->StandardFields.Magic == PE32P_MAGIC) {
		return &SEEK_AFTER(PE32_DATA_DIR, PeFile->Pe32pHeader->DataDirectories, Index);
	}
	return 0;
}

PEREADER_ERROR
PeReaderCopyDataRawToLoaded(
	IN OUT PPE_FILE PeFile
)
{
	ULONG i;
	
	// For every section
	CHK_ADDR(PeFile->CoffHeader, sizeof(COFF_HEADER));
	CHK_ADDR(PeFile->SectionHeaders, 
		sizeof(SECTION_HEADER) * PeFile->CoffHeader->NumberOfSections);
	
	for (i = 0; i < PeFile->CoffHeader->NumberOfSections; i++) {
		ULONG CopySize, SpaceSize;
		PUCHAR PRawData, PLoadData;
		
		// Ignore sections need not to load
		if (PeFile->SectionHeaders[i].VirtualSize) {

			PRawData = PeFile->RawData + PeFile->SectionHeaders[i].PointerToRawData;
			PLoadData = PeFile->LoadedData + PeFile->SectionHeaders[i].VirtualAddress;
			CopySize = MIN(PeFile->SectionHeaders[i].VirtualSize, PeFile->SectionHeaders[i].SizeOfRawData);
			SpaceSize = PeFile->SectionHeaders[i].VirtualSize - CopySize;
			
			// Copy the raw data, clean the uninitialized spaces
			CHK_ADDR(PRawData, CopySize);			
			memcpy(PLoadData, PRawData, CopySize);
			memset(PLoadData + CopySize, SpaceSize, 0);
		}
		
	}
	
	return PEREADER_NO_ERROR;
}

PUCHAR
RelocationBlockEnd(
	PRELOCATION_BLOCK RelocationBlock
)
{
	return (PUCHAR)RelocationBlock + RelocationBlock->Header.BlockSize;
}

PUCHAR
DataDirEnd(
	PPE_FILE PeFile,
	PPE32_DATA_DIR DataDir
)
{
	return PeFile->LoadedData + DataDir->VirtualAddress + DataDir->Size;
}

PEREADER_ERROR
PeReaderRelocation(
	IN OUT PPE_FILE PeFile
)
{
	ULONG PeImageBase;
	PPE32_DATA_DIR RelocationDataDir;
	PRELOCATION_BLOCK RelocationBlock;

	// Get ImageBase
	PeImageBase = PeReaderGetImageBase(PeFile);
	
	// Check whether need to relocate
	if ((ULONG)PeFile->LoadBaseAddress == PeImageBase) {
		return PEREADER_NO_ERROR;
	}
		
	// Check whether able to relocate
	if (PeFile->CoffHeader->Characteristics & IMAGE_FILE_RELOCS_STRIPPED) {
		return PEREADER_RELOCATION_DEPRECATED;
	}

	// Get the data directory of .reloc
	RelocationDataDir =
		PeReaderGetDataDirectory(PeFile, IMAGE_DATA_DIR_BASE_RELOCATION_TABLE);

	// Get the first relocation block
	RelocationBlock = (PRELOCATION_BLOCK)
		(PeFile->LoadedData + RelocationDataDir->VirtualAddress);

	// For every relocation block(while the next block is belong to the relocation data)
	while (RelocationBlockEnd(RelocationBlock) <= DataDirEnd(PeFile, RelocationDataDir)
		&& RelocationBlock->Header.BlockSize >= 8) {
		
		ULONG i, EntriesInBlock;
		PRELOCATION_BLOCK_ENTRY RelocationEntry;

#ifdef PEREADER_DEBUG
		printf("Block RVA: %08x\n", RelocationBlock->Header.PageRVA);
#endif
		// Calculate the number of entries
		EntriesInBlock = (RelocationBlock->Header.BlockSize - 8) / 2;

		// For every entry
		RelocationEntry = &RelocationBlock->Entries;
		for (i = 0; i < EntriesInBlock; i++) {

			PULONG RelocationPointer;

#ifdef PEREADER_DEBUG
			printf("\tRelocation: %06x\tType: %d\t%08x\n", RelocationEntry->Offset,
				RelocationEntry->Type, *RelocationPointer);
#endif
			// The position to relocate
			RelocationPointer = (PULONG)(PeFile->LoadedData +
				RelocationBlock->Header.PageRVA+ RelocationEntry->Offset);

			// Relocation type
			switch (RelocationEntry->Type) {
			case 0:
				// No need to relocate
				break;
			case 3:
				// Relocate
				*RelocationPointer = *RelocationPointer - PeImageBase + PeFile->LoadBaseAddress;
				break;
			default:
				// Not supported
				return PEREADER_RELOCATION_TYPE_NOT_SUPPORTED;
			}

			// Annoying structure word alignment T_T
			RelocationEntry = (PRELOCATION_BLOCK_ENTRY)((PUCHAR)RelocationEntry + 2);
				
		}

		// Next relocation block, followed current block immediately
		RelocationBlock = (PRELOCATION_BLOCK)RelocationBlockEnd(RelocationBlock);

#ifdef PEREADER_DEBUG
		printf("Next Block: %08x, Boundary: %08x\n", 	RelocationBlockEnd(RelocationBlock),
			DataDirEnd(PeFile, RelocationDataDir));
#endif
	}
	
	return PEREADER_NO_ERROR;
}

PEREADER_ERROR
PeReaderLoad(
	IN OUT PPE_FILE PeFile
)

/*

	Function:
	
		PeReaderLoad

	Description:

		Load the PE file from RawData to LoadedData, commit relocation with base
		address LoadBaseAddress.

	Arguments:

		PeFile - The data structure to commit.

	Return:

		The exit code.

*/

{
	PEREADER_ERROR ReturnValue;
	
	if (PeFile->FileType == PETYPE_INVALID_PE) {
		return PEREADER_INVALID_PE_FORMAT;
	}
	if (PeFile->FileStat == PEFILE_NOT_PARSED) {
		return PEREADER_PE_NOT_PARSED;
	}

	// Initialize
	PeFile->FileStat = PEFILE_NOT_LOADED;

	ReturnValue = PeReaderCopyDataRawToLoaded(PeFile);
	if (ReturnValue != PEREADER_NO_ERROR) {
		return ReturnValue;
	}
	ReturnValue = PeReaderRelocation(PeFile);
	if (ReturnValue != PEREADER_NO_ERROR) {
		return ReturnValue;
	}

	PeFile->FileStat = PEFILE_LOADED;
	
	return PEREADER_NO_ERROR;
}

PEREADER_ERROR
PeReaderSeekExportedName(
	IN OUT PPE_FILE PeFile,
	IN PCHAR ExportedName,
	OUT PPVOID VirtualAddr
)

/*

	Function:
	
		PeReaderSeekExportedName

	Description:

		Seek the specified name from PE Export Table.

	Arguments:

		PeFile - The data structure to seek.
		ExportedName - The name to seek.
		VirtualAddr - Seek result, virtual address(RVA + LoadBaseAddress).

	Return:

		The exit code.

*/

{
	ULONG i;
	PULONG NamePointerTable;
	PPE32_DATA_DIR ExportTableDir;
	PEXPORT_DIRECTORY_TABLE ExportDirectoryTable;

	if (PeFile->FileStat != PEFILE_LOADED) {
		return PEREADER_PE_NOT_LOADED;
	}

	// Get Export Table Data Directory
	ExportTableDir = PeReaderGetDataDirectory(PeFile, IMAGE_DATA_DIR_EXPORT_TABLE);

	// Get Export Directory Table
	ExportDirectoryTable = (PEXPORT_DIRECTORY_TABLE)(PeFile->LoadedData +
		ExportTableDir->VirtualAddress);

	// Get Name Pointer Table
	NamePointerTable = (PULONG)(PeFile->LoadedData + ExportDirectoryTable->NamePointerRva);

#ifdef PEREADER_DEBUG
	printf("Export Table Interval: [%08x, %08x)\n", ExportTableDir->VirtualAddress, 
		ExportTableDir->VirtualAddress + ExportTableDir->Size);
	printf("Export Name Table:\n");
#endif

	// For every name in the export table
	for (i = 0; i < ExportDirectoryTable->NumberNamePointers; i++) {
		
#ifdef PEREADER_DEBUG
		printf("\t%s\n", PeFile->LoadedData + NamePointerTable[i]);
#endif

		// Compare the name string
		if (!strcmp(PeFile->LoadedData + NamePointerTable[i], ExportedName)) {
			ULONG Ordinal;
			PEXPORT_ADDRESS_TABLE ExportAddressEntry;

			// Get Ordinal
			Ordinal = ((PUSHORT)(PeFile->LoadedData + ExportDirectoryTable->OrdinalTableRva))[i];

			// Get Export Address Table Entry
			ExportAddressEntry = (PEXPORT_ADDRESS_TABLE)
				(PeFile->LoadedData + ExportDirectoryTable->ExportAddressTableRva);
			ExportAddressEntry += Ordinal;// - ExportDirectoryTable->OrdinalBase;
#ifdef PEREADER_DEBUG
			printf("Ordinal: %d\tBase: %d\n", Ordinal, ExportDirectoryTable->OrdinalBase);
#endif

			// Check if it is an Export RVA
			if (ExportAddressEntry->ForwarderRva >= ExportTableDir->VirtualAddress &&
				ExportAddressEntry->ForwarderRva < ExportTableDir->VirtualAddress + ExportTableDir->Size) {
#ifdef PEREADER_DEBUG
				printf("Forward RVA: %08x\n", ExportAddressEntry->ForwarderRva);
				printf("\tString: '%s'\n", PeFile->LoadedData + ExportAddressEntry->ForwarderRva);
#endif
				return PEREADER_FORWARD_EXPORT;
			}
			
#ifdef PEREADER_DEBUG
			printf("Exported Name found, RVA: %08x\n", ExportAddressEntry->ExportRva);
#endif
			*VirtualAddr = (PVOID)(ExportAddressEntry->ExportRva + PeFile->LoadBaseAddress);
			
			return PEREADER_NO_ERROR;
		}
	}
	
	return PEREADER_EXPORT_NAME_NOT_FOUND;
}
