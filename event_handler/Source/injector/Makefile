proj		= injector
tester		= testinjector

projdir		= .
pereader	= ../pereader
pub			= ../../public

incs		= -I$(projdir)/inc -I$(pub)/sdk/inc -I$(pereader)/inc
defs		= -D_X86_=1 -Di386=1 -DFPO=0 -DDBG=0 -DNDEBUG

lib1		= lib/$(proj).lib
lib2		= $(pereader)/lib/pereader.lib
libs		= $(lib1) $(lib2)
obj1		= obj/$(proj).obj
obj2		= obj/syscall.obj
obj3		= obj/$(tester).obj
objs		= $(obj1) $(obj2) $(obj3)

testerexe	= bin/$(tester).exe
testerc		= src/$(tester).c

CC			= cl.exe -nologo
CFLAGS		= $(incs) $(defs) $(copts)
LIBS		= lib.exe -nologo
AS			= ml -nologo

all:		$(libs) $(testerexe)

$(lib1):	$(obj1) $(obj2)
	@echo "  (LIB) $@"
	@$(LIBS) $^ -out:$@

$(obj1):	src/$(proj).c
	@echo "  (CC) $@"
	@$(CC) $(CFLAGS) /c -Fo$@ $^

$(obj2):	src/syscall.asm
	@echo "  (AS) $@"
	@$(AS) /c /Fo$@ $^

$(testerexe):	$(testerc) $(libs)
	@echo "  (CC) $@"
	@$(CC) $(CFLAGS) -Fe$@ -Fo$(obj3) $^

clean:
	@echo "  (DEL)"
	@rm -r $(lib1) $(objs) $(testerexe)
