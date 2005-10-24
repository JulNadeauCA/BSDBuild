# $Csoft: Makefile,v 1.27 2005/04/25 04:34:14 vedge Exp $

TOP=..

SHARE=	Core.pm \
	cc.pm \
	glib.pm \
	sdl.pm \
	sdl_image.pm \
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
	setlocale.pm \
	gettext.pm \
	fastcgi.pm \
	csoftadm.pm \
	arc4random.pm \
	pctr.pm \
	getpwuid.pm \
	getuid.pm \
	agar.pm \
	csoft-cgi.pm \
	libqnet.pm \
	md5.pm \
	sha1.pm \
	rmd160.pm \
	pthreads.pm \
	sys_types.pm \
	free_null.pm \
	agar-net.pm

all:

install:
	@if [ ! -d "${SHAREDIR}/Manuconf" ]; then \
	    echo "${INSTALL_DATA_DIR} ${SHAREDIR}/Manuconf"; \
	    ${INSTALL_DATA_DIR} ${SHAREDIR}/Manuconf; \
	fi; \
	for F in ${SHARE}; do \
	    echo "${INSTALL_DATA} $$F ${SHAREDIR}/Manuconf"; \
	    ${INSTALL_DATA} $$F ${SHAREDIR}/Manuconf; \
	done

install-links:
	@if [ ! -d "${SHAREDIR}/Manuconf" ]; then \
	    echo "${INSTALL_DATA_DIR} ${SHAREDIR}/Manuconf"; \
	    ${INSTALL_DATA_DIR} ${SHAREDIR}/Manuconf; \
	fi; \
	for F in ${SHARE}; do \
	    echo "ln -sf `pwd`/$$F ${SHAREDIR}/Manuconf/$$F"; \
	    ln -sf `pwd`/$$F ${SHAREDIR}/Manuconf/$$F; \
	done

cleandir:
	rm -f *~

.PHONY: install install-links cleandir

include ${TOP}/csoft.common.mk
include ${TOP}/csoft.subdir.mk
include ${TOP}/Makefile.config
