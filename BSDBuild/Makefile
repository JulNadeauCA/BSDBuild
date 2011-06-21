TOP=..

SHARE=	Core.pm \
	Builtins.pm \
	cc.pm \
	cxx.pm \
	glib.pm \
	glib2.pm \
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
	arc4random.pm \
	pctr.pm \
	getpwuid.pm \
	getuid.pm \
	md5.pm \
	sha1.pm \
	rmd160.pm \
	pthreads.pm \
	sys_types.pm \
	sys_queue.pm \
	free_null.pm \
	agar.pm \
	agar-core.pm \
	agar-rg.pm \
	agar-vg.pm \
	agar-dev.pm \
	agar-au.pm \
	cg.pm \
	cracklib.pm \
	db4.pm \
	perl.pm \
	libidn.pm \
	getaddrinfo.pm \
	glu.pm \
	ode.pm \
	sse.pm \
	setjmp.pm \
	signal.pm \
	altivec.pm \
	unistd_h.pm \
	stdlib_h.pm \
	limits_h.pm \
	strtoll.pm \
	strtold.pm \
	open_exlock.pm \
	fgetln.pm \
	Mail-SpamAssassin.pm \
	getpeerucred.pm \
	so_peercred.pm \
	getpeereid.pm \
	freesg.pm \
	math_c99.pm \
	getopt.pm \
	byte_order.pm \
	iconv.pm \
	curl.pm \
	edacious.pm \
	dlopen.pm \
	dyld.pm \
	shl_load.pm \
	float_h.pm \
	agar-math.pm \
	percgi.pm \
	gettimeofday.pm \
	syslog.pm \
	glob.pm \
	glx.pm \
	png.pm \
	alsa.pm \
	wgl.pm \
	mgid.pm \
	select.pm \
	sndfile.pm \
	execvp.pm \
	libbsd.pm \
	clock_gettime.pm \
	clock_win32.pm \
	sdl_ttf.pm \
	xinerama.pm \
	portaudio.pm

all:

install:
	@if [ ! -d "${DESTDIR}${SHAREDIR}/BSDBuild" ]; then \
	    echo "${INSTALL_DATA_DIR} ${SHAREDIR}/BSDBuild"; \
	    ${SUDO} ${INSTALL_DATA_DIR} ${DESTDIR}${SHAREDIR}/BSDBuild; \
	fi; \
	for F in ${SHARE}; do \
	    echo "${INSTALL_DATA} $$F ${SHAREDIR}/BSDBuild"; \
	    ${SUDO} ${INSTALL_DATA} $$F ${DESTDIR}${SHAREDIR}/BSDBuild; \
	done

install-links:
	@if [ ! -d "${DESTDIR}${SHAREDIR}/BSDBuild" ]; then \
	    echo "${INSTALL_DATA_DIR} ${SHAREDIR}/BSDBuild"; \
	    ${SUDO} ${INSTALL_DATA_DIR} ${DESTDIR}${SHAREDIR}/BSDBuild; \
	fi; \
	for F in ${SHARE}; do \
	    echo "ln -sf `pwd`/$$F ${SHAREDIR}/BSDBuild/$$F"; \
	    ${SUDO} ln -sf `pwd`/$$F ${DESTDIR}${SHAREDIR}/BSDBuild/$$F; \
	done

clean:

cleandir:

.PHONY: install install-links

include ${TOP}/build.common.mk
include ${TOP}/build.subdir.mk
include ${TOP}/Makefile.config
