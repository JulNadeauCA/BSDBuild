# $Csoft: Makefile,v 1.16 2003/03/25 11:37:05 vedge Exp $

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
	jpeg.pm \
	gethostname.pm \
	snprintf.pm \
	vsnprintf.pm \
	setlocale.pm

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
