proj		= pereader
tester		= petester

projdir		= .
pub			= ../../public

incs		= -I$(projdir)/inc -I$(pub)/sdk/inc
defs		= -D_X86_=1 -Di386=1 -DFPO=0 -DDBG=0 -DNDEBUG

libs		= lib/$(proj).lib
objs		= obj/$(proj).obj
cs			= src/$(proj).c

testerexe	= bin/$(tester).exe
testerc		= src/$(tester).c

CC			= cl.exe -nologo
CFLAGS		= $(incs) $(defs)
LIBS		= lib.exe -nologo
LINK		= link.exe -nologo
LINKFLAGS	= $(inclibs)

all:		$(libs) $(testerexe)

$(libs):	$(objs)
	@echo "  (LIB) $@"
	@$(LIBS) $(objs) -out:$@

$(objs):	$(cs)
	@echo "  (CC) $@"
	@$(CC) $(CFLAGS) /c $(cs) -Fo$@

$(testerexe):	$(testerc) $(libs)
	@echo "  (CC) $@"
	@$(CC) $(CFLAGS) -Fe$@ -Foobj/$(tester).obj $(testerc) lib/$(proj).lib

clean:
	@echo "  (DEL)"
	@rm $(libs) $(objs) $(testerexe) obj/$(tester).obj
