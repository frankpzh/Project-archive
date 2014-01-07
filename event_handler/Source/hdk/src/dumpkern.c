#include <stdio.h>
#include <string.h>
#include <cvconst.h>
#include <windows.h>
#include <dbghelp.h>

HANDLE Index = (HANDLE)1;
ULONG64 buffer[(sizeof(SYMBOL_INFO) + MAX_SYM_NAME*sizeof(TCHAR) + sizeof(ULONG64) - 1) / sizeof(ULONG64)];
PSYMBOL_INFO SymbolInfo;
DWORD64 BaseAddress;

int DoStuff(char *);

/*BOOL CALLBACK TestType(
  PSYMBOL_INFO pSymInfo,
  ULONG SymbolSize,
  PVOID UserContext
)
{
	DWORD Tag, Nested;
	
	SymGetTypeInfo(Index, BaseAddress, pSymInfo->TypeIndex, TI_GET_SYMTAG, &Tag);
	if (Tag == SymTagUDT)
		fprintf(stderr, "UDT: %x %s\n", pSymInfo->Flags, pSymInfo->Name);
	else if (Tag == SymTagTypedef) {
		SymGetTypeInfo(Index, BaseAddress, pSymInfo->Index, TI_GET_NESTED, &Nested);
		fprintf(stderr, "Typedef: %x %s\n", Nested, pSymInfo->Name);
	}
	return TRUE;
}*/

int main(int argc, char *argv[]) {
	int ReturnValue;

	if (argc != 3) {
		fprintf(stderr, "Usage: %s <hdk.h> <wrkx86.exe>\n", argv[0]);
		return 1;
	}
	
	if (!SymInitialize(Index, NULL, FALSE)) {
		fprintf(stderr, "SymInitialize Error.\n");
		return 1;
	}

	BaseAddress = SymLoadModule64(Index, NULL, argv[2], NULL, 0x80800000, 0);
	if (!BaseAddress) {
		fprintf(stderr, "Unable to load module.\n");
		SymCleanup(Index);
		return 1;
	}

	SymbolInfo = (PSYMBOL_INFO)buffer;
	SymbolInfo->SizeOfStruct = sizeof(SYMBOL_INFO);
	SymbolInfo->MaxNameLen = MAX_SYM_NAME;
	ReturnValue = DoStuff(argv[1]);

	//SymEnumTypes(Index, BaseAddress, TestType, 0);
	
	SymUnloadModule64(Index, BaseAddress);
	
	SymCleanup(Index);
	
	return ReturnValue;
}

int DoStuff(char *HFileName) {
	FILE *HFile;
	char *Op1, *Op2;
	char Buffer[256];

	if (fopen_s(&HFile, HFileName, "rb")) {
		fprintf(stderr, "Could not open header file.\n");
		return 1;
	}
	printf("// Searching symbols...\n");
	while (fgets(Buffer, 255, HFile)) {
		if (!strncmp(Buffer, "extern ", 7)) {
			Op1 = Buffer;
			while (*Op1 != '(') Op1++;
			while (*Op1 != '*') Op1++;
			Op1++;
			while (*Op1 == ' ' || *Op1 == '\t') Op1++;
			Op2 = Op1;
			while (*Op2 != ' ' && *Op2 != '\t' && *Op2 != ')') Op2++;
			
			Buffer[255] = *Op2;
			*Op2 = '\0';
			if (!SymFromName(Index, Op1, SymbolInfo)) {
				fprintf(stderr, "Could not found the symbol: %s\n", Op1);
				fclose(HFile);
				return 1;
			}
			*Op2 = Buffer[255];
			
			while (*Op2 != ';') Op2++;
			*Op2 = '\0';
			printf("\t%s = 0x%08x;\n", &Buffer[7], SymbolInfo->Address);
		}
	}
	fclose(HFile);
	
	return 0;
}

