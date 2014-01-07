#ifndef _PEREADER_
#define _PEREADER_

#include "nt.h"
#include "pe.h"
#include "reloc.h"
#include "edata.h"

#define MAX(a, b) (((a)>(b))?(a):(b))
#define MIN(a, b) (((a)<(b))?(a):(b))
#define UPDATE_MAX(a, b) if ((a) < (b)) (a) = (b)
#define UPDATE_MIN(a, b) if ((a) > (b)) (a) = (b)
#define SEEK_AFTER(type, var, i) (*((type*)(&var) + i))

typedef PCHAR *PPCHAR;

typedef enum _PE_TYPE {
	PETYPE_INVALID_PE,
	PETYPE_PE32_EXE,
	PETYPE_PE32_DLL,
	PETYPE_PE32P_EXE,
	PETYPE_PE32P_DLL,
	PETYPE_OTHER
	} PE_TYPE;

typedef enum _PEREADER_ERROR {
	PEREADER_NO_ERROR,
	PEREADER_INVALID_PE_FORMAT,
	PEREADER_RELOCATION_DEPRECATED,
	PEREADER_RELOCATION_TYPE_NOT_SUPPORTED,
	PEREADER_PE_NOT_PARSED,
	PEREADER_PE_NOT_LOADED,
	PEREADER_EXPORT_NAME_NOT_FOUND,
	PEREADER_FORWARD_EXPORT
	} PEREADER_ERROR;

typedef enum _PE_FILE_STAT {
	PEFILE_NOT_PARSED,
	PEFILE_NOT_LOADED,
	PEFILE_LOADED
	} PE_FILE_STAT;

typedef struct _PE_FILE {
	PUCHAR RawData;
	ULONG RawDataSize;
	ULONG LoadBaseAddress;
	PUCHAR LoadedData;
	ULONG LoadedDataSize;
	PE_TYPE FileType;
	PE_FILE_STAT FileStat;
	PCOFF_HEADER CoffHeader;
	union {
		PPE32_HEADER Pe32Header;
		PPE32P_HEADER Pe32pHeader;
	};
	PSECTION_HEADER SectionHeaders;
} PE_FILE, *PPE_FILE;

PEREADER_ERROR
PeReaderParsePe(
	IN OUT PPE_FILE PeFile
);

PEREADER_ERROR
PeReaderGetLoadedSize(
	IN OUT PPE_FILE PeFile
);

PEREADER_ERROR
PeReaderLoad(
	IN OUT PPE_FILE PeFile
);

PEREADER_ERROR
PeReaderSeekExportedName(
	IN OUT PPE_FILE PeFile,
	IN PCHAR ExportedName,
	OUT PPVOID VirtualAddr
);

#endif
