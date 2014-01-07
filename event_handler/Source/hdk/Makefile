CC			= cl -nologo
CFLAGS		= -Gz $(incs)

wrkdir		= ../../base/ntos/BUILD/EXE
wrkexe		= $(wrkdir)/wrkx86.exe $(wrkdir)/wrkx86.pdb
wrkkern		= kern/wrkx86.exe

incs		= -Iinc -I"C:\Program Files\Microsoft Visual Studio 8\DIA SDK\include" \
		  -I"D:\Develop\Microsoft Visual Studio 8\DIA SDK\include"

handler		= cphandler
handlerdll	= bin/$(handler).dll
handlersrc	= src/$(handler).c

dumpkern	= dumpkern
dumpkernexe	= bin/$(dumpkern).exe
dumpkernsrc = src/$(dumpkern).c

kernfunc	= inc/kernfunc.inc

all:			$(dumpkernexe) $(kernfunc) $(handlerdll)

$(dumpkernexe):	$(dumpkernsrc)
	@echo "  (CC) $@"
	@$(CC) $(CFLAGS) dbghelp.lib -Fe$@ -Foobj/$(dumpkern).obj $^

$(kernfunc):	$(dumpkernexe) $(wrkkern)
	@echo "  (DUMPKERN)"
	@$(dumpkernexe) inc/hdk.h kern/wrkx86.exe > $@

$(handlerdll):	$(kernfunc) $(handlersrc)
	@echo "  (CC) $@"
	@$(CC) $(CFLAGS) /LD -Fe$@ -Foobj/$(handler).obj $(handlersrc)
	@cp bin/$(handler).exp lib > NUL
	@cp bin/$(handler).lib lib > NUL
	@rm bin/$(handler).exp bin/$(handler).lib

$(wrkkern):		$(wrkexe)
	@echo "  (CP) wrkx86"
	@cp $(wrkdir)/wrkx86.exe kern > NUL
	@cp $(wrkdir)/wrkx86.pdb kern > NUL

clean:
	@echo "  (DEL)"
	@rm -r $(dumpkernexe) $(kernfunc) $(handlerdll) $(wrkkern) obj/*.obj
