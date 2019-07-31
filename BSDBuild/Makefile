TOP=..

DATAFILES=Core.pm \
	Builtins.pm \
	ada.pm \
	cc.pm \
	cc_attributes.pm \
	objc.pm \
	cxx.pm \
	gcc.pm \
	glib.pm \
	glib2.pm \
	sdl.pm \
	sdl_image.pm \
	sdl_cpuinfo.pm \
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
	getpwnam_r.pm \
	getuid.pm \
	pthreads.pm \
	sys_stat.pm \
	sys_types.pm \
	sys_queue.pm \
	free_null.pm \
	agar.pm \
	agar.defs.pm \
	agar-ada.pm \
	agar-ada-core.pm \
	agar-au.pm \
	agar-core.pm \
	agar-core.defs.pm \
	agar-dev.pm \
	agar-map.pm \
	agar-math.pm \
	agar-rg.pm \
	agar-sg.pm \
	agar-sk.pm \
	agar-vg.pm \
	cg.pm \
	cracklib.pm \
	db4.pm \
	db5.pm \
	perl.pm \
	libidn.pm \
	getaddrinfo.pm \
	gethostbyname.pm \
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
	freesg-rg.pm \
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
	portaudio.pm \
	mysql.pm \
	cocoa.pm \
	sockopts.pm \
	crypt.pm \
	winsock.pm \
	siocgifconf.pm \
	fontconfig.pm \
	rand48.pm \
	nanosleep.pm \
	kqueue.pm \
	timerfd.pm \
	etubestore.pm \
	uim.pm \
	xbox.pm \
	csidl.pm \
	libircclient.pm \
	pcre.pm \
	imagemagick.pm \
	zlib.pm \
	fdclose.pm \
	lldb.pm \
	tcl.pm

all:

install:
	@if [ ! -d "${DESTDIR}${DATADIR}/BSDBuild" ]; then \
	    echo "${INSTALL_DATA_DIR} ${DATADIR}/BSDBuild"; \
	    ${SUDO} ${INSTALL_DATA_DIR} ${DESTDIR}${DATADIR}/BSDBuild; \
	fi; \
	for F in ${DATAFILES}; do \
	    echo "${INSTALL_DATA} $$F ${DATADIR}/BSDBuild"; \
	    ${SUDO} ${INSTALL_DATA} $$F ${DESTDIR}${DATADIR}/BSDBuild; \
	done

deinstall:
	@for F in ${DATAFILES}; do \
	    echo "${DEINSTALL_DATA} ${DATADIR}/BSDBuild/$$F"; \
	    ${SUDO} ${DEINSTALL_DATA} ${DESTDIR}${DATADIR}/BSDBuild/$$F; \
	done

install-links:
	@if [ ! -d "${DESTDIR}${DATADIR}/BSDBuild" ]; then \
	    echo "${INSTALL_DATA_DIR} ${DATADIR}/BSDBuild"; \
	    ${SUDO} ${INSTALL_DATA_DIR} ${DESTDIR}${DATADIR}/BSDBuild; \
	fi; \
	for F in ${DATAFILES}; do \
	    echo "ln -sf `pwd`/$$F ${DATADIR}/BSDBuild/$$F"; \
	    ${SUDO} ln -sf `pwd`/$$F ${DESTDIR}${DATADIR}/BSDBuild/$$F; \
	done

clean:

cleandir:

.PHONY: install install-links

include ${TOP}/build.common.mk
include ${TOP}/build.subdir.mk
include ${TOP}/Makefile.config
