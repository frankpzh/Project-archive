#include <stdio.h>
#include <malloc.h>
#include "pereader.h"

int main(int argc, char *argv[]) {
	int i, r;
	FILE *fin;
	PE_FILE pe;
	PVOID pointer;
	
	if (argc != 2) {
		printf("Invalid usage.\n");
		return 1;
	}
	
	if (fopen_s(&fin, argv[1], "rb")) {
		printf("Unable to open file %s.\n", argv[1]);
		return 1;
	}

	fseek(fin, 0, SEEK_END);
	pe.RawDataSize = ftell(fin);
	fseek(fin, 0, SEEK_SET);
	printf("File Size: %d Bytes\n", pe.RawDataSize);
	pe.RawData = (PUCHAR)malloc(pe.RawDataSize);
	fread(pe.RawData, 1, pe.RawDataSize, fin);
	if ((r = PeReaderParsePe(&pe)) != PEREADER_NO_ERROR) {
		printf("Parse error %d\n", r);
		return 1;
	}
	printf("Number of Sections: %d\n", pe.CoffHeader->NumberOfSections);
	for (i = 0; i < pe.CoffHeader->NumberOfSections; i++)
		printf("\tSection #%d: %s\n", i, pe.SectionHeaders[i].Name);
	if ((r = PeReaderGetLoadedSize(&pe)) != PEREADER_NO_ERROR) {
		printf("GetLoadedSize error %d\n", r);
		return 1;
	}
	printf("Loaded Size: %d Bytes\n", pe.LoadedDataSize);
	printf("File Type: %d\n", pe.FileType);
	pe.LoadBaseAddress = 0x10000000;
	pe.LoadedData = (PUCHAR)malloc(pe.LoadedDataSize);
	PeReaderLoad(&pe);
	r = PeReaderSeekExportedName(&pe, "OleUIBusyA", &pointer);
	printf("Return value: %d, Function entry: %08x\n", r, pointer);
	free(pe.LoadedData);
	free(pe.RawData);
	
	fclose(fin);

	return 0;
}
