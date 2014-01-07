.PHONY: all clean

AR=../kamikaze/staging_dir/toolchain-mipsel_gcc4.1.2/bin/mipsel-linux-ar
CC=../kamikaze/staging_dir/toolchain-mipsel_gcc4.1.2/bin/mipsel-linux-gcc
CFLAGS=-D_LINUX -D_POSIX

LIBOBJS=des.o dot1x.o ethcard_eth.o logs.o md5.o mytunetsvc.o os.o os_posix.o setting.o tunet.o userconfig.o util.o
TARLIB=libmytunet.a
EXEOBJS=main.o
TAREXE=mytunet

all: $(TARLIB) $(TAREXE) mii_switch

$(TARLIB): $(LIBOBJS)
	$(AR) r $@ $^

$(TAREXE): $(EXEOBJS) $(LIBOBJS)
	$(CC) $(CFLAGS) -lpthread $^ -o $@

mii_switch: mii_switch.o
	$(CC) $(CFLAGS) $^ -o $@

clean:
	rm -f $(TARLIB) $(TAREXE) mii_switch mii_switch.o $(LIBOBJS) $(EXEOBJS)
