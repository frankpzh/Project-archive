#ifndef _PE_
#define _PE_

#include "coff.h"
#include "reloc.h"

typedef struct _PE32_STD_FIELD {
	USHORT Magic;
	UCHAR MajorLinkerVersion;
	UCHAR MinorLinkerVersion;
	ULONG SizeOfCode;
	ULONG SizeOfInitializedData;
	ULONG SizeOfUninitializedData;
	ULONG AddressOfEntryPoint;
	ULONG BaseOfCode;
	ULONG BaseOfData;
} PE32_STD_FIELD, *PPE32_STD_FIELD;

typedef struct _PE32P_STD_FIELD {
	USHORT Magic;
	UCHAR MajorLinkerVersion;
	UCHAR MinorLinkerVersion;
	ULONG SizeOfCode;
	ULONG SizeOfInitializedData;
	ULONG SizeOfUninitializedData;
	ULONG AddressOfEntryPoint;
	ULONG BaseOfCode;
} PE32P_STD_FIELD, *PPE32P_STD_FIELD;

#define PE32_MAGIC		0x10b
#define PE32P_MAGIC		0x20b

typedef struct _PE32_WIN_SPEC_FIELD {
	ULONG ImageBase;
	ULONG SectionAlignment;
	ULONG FileAlignment;
	USHORT MajorOperatingSystemVersion;
	USHORT MinorOperatingSystemVersion;
	USHORT MajorImageVersion;
	USHORT MinorImageVersion;
	USHORT MajorSubsystemVersion;
	USHORT MinorSubsystemVersion;
	ULONG Win32VersionValue;
	ULONG SizeOfImage;
	ULONG SizeOfHeaders;
	ULONG CheckSum;
	USHORT Subsystem;
	USHORT DllCharacteristics;
	ULONG SizeOfStackReserve;
	ULONG SizeOfStackCommit;
	ULONG SizeOfHeapReserve;
	ULONG SizeOfHeapCommit;
	ULONG LoaderFlags;
	ULONG NumberOfRvaAndSizes;
} PE32_WIN_SPEC_FIELD, *PPE32_WIN_SPEC_FIELD;

typedef struct _PE32P_WIN_SPEC_FIELD {
	UQUAD ImageBase;
	ULONG SectionAlignment;
	ULONG FileAlignment;
	USHORT MajorOperatingSystemVersion;
	USHORT MinorOperatingSystemVersion;
	USHORT MajorImageVersion;
	USHORT MinorImageVersion;
	USHORT MajorSubsystemVersion;
	USHORT MinorSubsystemVersion;
	ULONG Win32VersionValue;
	ULONG SizeOfImage;
	ULONG SizeOfHeaders;
	ULONG CheckSum;
	USHORT Subsystem;
	USHORT DllCharacteristics;
	UQUAD SizeOfStackReserve;
	UQUAD SizeOfStackCommit;
	UQUAD SizeOfHeapReserve;
	UQUAD SizeOfHeapCommit;
	ULONG LoaderFlags;
	ULONG NumberOfRvaAndSizes;
} PE32P_WIN_SPEC_FIELD, *PPE32P_WIN_SPEC_FIELD;

#define IMAGE_SUBSYSTEM_UNKNOW						0
#define IMAGE_SUBSYSTEM_NATIVE						1
#define IMAGE_SUBSYSTEM_WINDOWS_GUI					2
#define IMAGE_SUBSYSTEM_WINDOWS_CUI					3
#define IMAGE_SUBSYSTEM_POSIX_CUI						7
#define IMAGE_SUBSYSTEM_WINDOWS_CE_GUI				9
#define IMAGE_SUBSYSTEM_EFI_APPLICATION				10
#define IMAGE_SUBSYSTEM_EFI_BOOT_SERVICE_DRIVER		11
#define IMAGE_SUBSYSTEM_EFI_RUNTIME_DRIVER			12
#define IMAGE_SUBSYSTEM_EFI_ROM						13
#define IMAGE_SUBSYSTEM_XBOX							14

#define IMAGE_DLL_CHARACTERISTICS_DYNAMIC_BASE				0x0040
#define IMAGE_DLL_CHARACTERISTICS_FORCE_INTEGRITY			0x0080
#define IMAGE_DLL_CHARACTERISTICS_NX_COMPAT					0x0100
#define IMAGE_DLL_CHARACTERISTICS_NO_ISOLATION				0x0200
#define IMAGE_DLL_CHARACTERISTICS_NO_SEH						0x0400
#define IMAGE_DLL_CHARACTERISTICS_NO_BIND					0x0800
#define IMAGE_DLL_CHARACTERISTICS_WDM_DRIVER				0x2000
#define IMAGE_DLL_CHARACTERISTICS_TERMINAL_SERVER_AWARE	0x8000

typedef struct _PE32_DATA_DIR {
	ULONG VirtualAddress;
	ULONG Size;
} PE32_DATA_DIR, *PPE32_DATA_DIR;

#define IMAGE_DATA_DIR_EXPORT_TABLE					0
#define IMAGE_DATA_DIR_IMPORT_TABLE					1
#define IMAGE_DATA_DIR_RESOURCE_TABLE				2
#define IMAGE_DATA_DIR_EXCEPTION_TABLE				3
#define IMAGE_DATA_DIR_CERTIFICATE_TABLE				4
#define IMAGE_DATA_DIR_BASE_RELOCATION_TABLE		5
#define IMAGE_DATA_DIR_DEBUG							6
#define IMAGE_DATA_DIR_ARCHITECTURE					7
#define IMAGE_DATA_DIR_GLOBAL_PTR					8
#define IMAGE_DATA_DIR_TLS_TABLE						9
#define IMAGE_DATA_DIR_LOAD_CONFIG_TABLE			10
#define IMAGE_DATA_DIR_BOUND_IMPORT					11
#define IMAGE_DATA_DIR_IAT								12
#define IMAGE_DATA_DIR_DELAY_IMPORT_DESCRIPTOR		13
#define IMAGE_DATA_DIR_CLR_RUNTIME_HEADER			14

typedef struct _SECTION_HEADER {
	CHAR Name[8];
	ULONG VirtualSize;
	ULONG VirtualAddress;
	ULONG SizeOfRawData;
	ULONG PointerToRawData;
	ULONG PointerToRelocations;
	ULONG PointerToLinenumbers;
	USHORT NumberOfRelocations;
	USHORT NumberOfLinenumbers;
	ULONG Characteristics;
} SECTION_HEADER, *PSECTION_HEADER;

#define IMAGE_SCN_TYPE_NO_PAD					0x00000008
#define IMAGE_SCN_CNT_CODE					0x00000020
#define IMAGE_SCN_CNT_INITIALIZED_DATA		0x00000040
#define IMAGE_SCN_CNT_UNINITIALIZED_DATA		0x00000080
#define IMAGE_SCN_LNK_OTHER					0x00000100
#define IMAGE_SCN_LNK_INFO						0x00000200
#define IMAGE_SCN_LNK_REMOVE					0x00000800
#define IMAGE_SCN_LNK_COMPAT					0x00001000
#define IMAGE_SCN_GPREL						0x00008000
//#define IMAGE_SCN_MEM_PURGEABLE				0x00010000
#define IMAGE_SCN_MEM_16BIT					0x00020000
#define IMAGE_SCN_MEM_LOCKED					0x00040000
#define IMAGE_SCN_MEM_PRELOAD				0x00080000
#define IMAGE_SCN_ALIGN_1BYTES				0x00100000
#define IMAGE_SCN_ALIGN_2BYTES				0x00200000
#define IMAGE_SCN_ALIGN_4BYTES				0x00300000
#define IMAGE_SCN_ALIGN_8BYTES				0x00400000
#define IMAGE_SCN_ALIGN_16BYTES				0x00500000
#define IMAGE_SCN_ALIGN_32BYTES				0x00600000
#define IMAGE_SCN_ALIGN_64BYTES				0x00700000
#define IMAGE_SCN_ALIGN_128BYTES				0x00800000
#define IMAGE_SCN_ALIGN_256BYTES				0x00900000
#define IMAGE_SCN_ALIGN_512BYTES				0x00A00000
#define IMAGE_SCN_ALIGN_1024BYTES				0x00B00000
#define IMAGE_SCN_ALIGN_2048BYTES				0x00C00000
#define IMAGE_SCN_ALIGN_4096BYTES				0x00D00000
#define IMAGE_SCN_ALIGN_8192BYTES				0x00E00000
#define IMAGE_SCN_LNK_NRELOC_OVFL			0x01000000
#define IMAGE_SCN_MEM_DISCARDABLE			0x02000000
#define IMAGE_SCN_MEM_NOT_CACHED			0x04000000
#define IMAGE_SCN_MEM_NOT_PAGED				0x08000000
#define IMAGE_SCN_MEM_SHARED					0x10000000
#define IMAGE_SCN_MEM_EXCUTE					0x20000000
#define IMAGE_SCN_MEM_READ					0x40000000
#define IMAGE_SCN_MEM_WRITE					0x80000000

typedef struct _PE32_HEADER {
	PE32_STD_FIELD StandardFields;
	PE32_WIN_SPEC_FIELD WindowsSpecificFields;
	PE32_DATA_DIR DataDirectories;
} PE32_HEADER, *PPE32_HEADER;

typedef struct _PE32P_HEADER {
	PE32P_STD_FIELD StandardFields;
	PE32P_WIN_SPEC_FIELD WindowsSpecificFields;
	PE32_DATA_DIR DataDirectories;
} PE32P_HEADER, *PPE32P_HEADER;

#endif