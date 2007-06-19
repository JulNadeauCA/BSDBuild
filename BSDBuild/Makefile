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
	md5.pm \
	sha1.pm \
	rmd160.pm \
	pthreads.pm \
	sys_types.pm \
	sys_queue.pm \
	free_null.pm \
	agar-net.pm \
	agar-sg.pm \
	agar-sc.pm \
	agar-rg.pm \
	agar-vg.pm \
	agar-map.pm \
	cg.pm \
	cracklib.pm \
	db4.pm \
	perl.pm \
	libidn.pm \
	getaddrinfo.pm \
	glu.pm

all:

install:
	@if [ ! -d "${SHAREDIR}/BSDBuild" ]; then \
	    echo "${INSTALL_DATA_DIR} ${SHAREDIR}/BSDBuild"; \
	    ${SUDO} ${INSTALL_DATA_DIR} ${SHAREDIR}/BSDBuild; \
	fi; \
	for F in ${SHARE}; do \
	    echo "${INSTALL_DATA} $$F ${SHAREDIR}/BSDBuild"; \
	    ${SUDO} ${INSTALL_DATA} $$F ${SHAREDIR}/BSDBuild; \
	done

install-links:
	@if [ ! -d "${SHAREDIR}/BSDBuild" ]; then \
	    echo "${INSTALL_DATA_DIR} ${SHAREDIR}/BSDBuild"; \
	    ${SUDO} ${INSTALL_DATA_DIR} ${SHAREDIR}/BSDBuild; \
	fi; \
	for F in ${SHARE}; do \
	    echo "ln -sf `pwd`/$$F ${SHAREDIR}/BSDBuild/$$F"; \
	    ${SUDO} ln -sf `pwd`/$$F ${SHAREDIR}/BSDBuild/$$F; \
	done

cleandir:
	rm -f *~

.PHONY: install install-links cleandir

include ${TOP}/build.common.mk
include ${TOP}/build.subdir.mk
include ${TOP}/Makefile.config
