# $Csoft: Makefile,v 1.14 2002/12/31 07:42:27 vedge Exp $

TOP=..

SHARE=	Core.pm \
	cc.pm \
	glib.pm \
	sdl.pm \
	sdl_ttf.pm \
	smpeg.pm \
	x11.pm \
	freetype.pm \
	setenv.pm \
	strlcat.pm \
	strlcpy.pm \
	strsep.pm \
	getenv.pm \
	vasprintf.pm \
	mmap.pm \
	setproctitle.pm \
	asprintf.pm \
	flock.pm \
	progname.pm \
	opengl.pm \
	math.pm \
	jpeg.pm

all:

regress:
	@for mod in ${SHARE}; do \
	    echo "$$mod"; \
	    perl "$$mod"; \
	done

install:
	@if [ ! -d "${SHAREDIR}/Manuconf" ]; then \
	    echo "${INSTALL_DATA_DIR} ${SHAREDIR}/Manuconf"; \
	    ${INSTALL_DATA_DIR} ${SHAREDIR}/Manuconf; \
	fi; \
	for F in ${SHARE}; do \
	    echo "${INSTALL_DATA} $$F ${SHAREDIR}/Manuconf"; \
	    ${INSTALL_DATA} $$F ${SHAREDIR}/Manuconf; \
	done

cleandir:
	rm -f *~

include ${TOP}/csoft.common.mk
include ${TOP}/csoft.subdir.mk
include ${TOP}/Makefile.config
