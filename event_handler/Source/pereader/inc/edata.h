#ifndef _EDATA_
#define _EDATA_

typedef struct _EXPORT_DIRECTORY_TABLE {
	ULONG ExportFlags;
	ULONG TimeDateStamp;
	USHORT MajorVersion;
	USHORT MinorVersion;
	ULONG NameRva;
	ULONG OrdinalBase;
	ULONG AddressTableEntries;
	ULONG NumberNamePointers;
	ULONG ExportAddressTableRva;
	ULONG NamePointerRva;
	ULONG OrdinalTableRva;
} EXPORT_DIRECTORY_TABLE, *PEXPORT_DIRECTORY_TABLE;

typedef struct _EXPORT_ADDRESS_TABLE {
	union {
		ULONG ExportRva;
		ULONG ForwarderRva;
	};
} EXPORT_ADDRESS_TABLE, *PEXPORT_ADDRESS_TABLE;

#endif
