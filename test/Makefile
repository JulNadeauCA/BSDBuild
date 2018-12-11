TOP=..

configure.in: gen-configure.pl
	perl gen-configure.pl > configure.in

configure: configure.in
	cat configure.in | mkconfigure > configure
	chmod 755 configure

clean:
	rm -rf configure configure.in Makefile.config config config.log config.status configure.lua

.PHONY: configure.in configure clean

include ${TOP}/build.common.mk
include ${TOP}/build.subdir.mk
include ${TOP}/Makefile.config
