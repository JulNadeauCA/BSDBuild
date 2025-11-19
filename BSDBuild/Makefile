TOP=..

DATAFILES=Core.pm Builtins.pm \
	ada.pm \
	Mail-SpamAssassin.pm \
	agar-ada-core.pm \
	agar-ada.pm \
	agar-au.pm \
	agar-core.defs.pm \
	agar-core.pm \
	agar-map.pm \
	agar-math.pm \
	agar-micro.pm \
	agar-net.pm \
	agar-sg.pm \
	agar-sk.pm \
	agar-vg.pm \
	agar.defs.pm \
	agar.pm \
	alsa.pm \
	altivec.pm \
	arc4random.pm \
	asprintf.pm \
	byte_order.pm \
	cc.pm \
	cc_attributes.pm \
	cg.pm \
	clock_gettime.pm \
	clock_win32.pm \
	cocoa.pm \
	cracklib.pm \
	crypt.pm \
	csidl.pm \
	curl.pm \
	cxx.pm \
	db4.pm \
	db5.pm \
	devkitpro.pm \
	dirfd.pm \
	dlopen.pm \
	dyld.pm \
	edacious.pm \
	etubestore.pm \
	execvp.pm \
	fastcgi.pm \
	fdclose.pm \
	fgetln.pm \
	float_h.pm \
	flock.pm \
	fontconfig.pm \
	free_null.pm \
	freetype.pm \
	gcc.pm \
	getaddrinfo.pm \
	getenv.pm \
	gethostbyname.pm \
	gethostname.pm \
	getopt.pm \
	getpeereid.pm \
	getpeerucred.pm \
	getpwnam_r.pm \
	getpwuid.pm \
	gettext.pm \
	gettimeofday.pm \
	getuid.pm \
	gle.pm \
	glew.pm \
	glib.pm \
	glib2.pm \
	glob.pm \
	glu.pm \
	glx.pm \
	iconv.pm \
	imagemagick.pm \
	jpeg.pm \
	kqueue.pm \
	libbsd.pm \
	libidn.pm \
	libircclient.pm \
	limits_h.pm \
	lldb.pm \
	lua.pm \
	math.pm \
	math_c99.pm \
	mgid.pm \
	mmap.pm \
	mprotect.pm \
	mysql.pm \
	nanosleep.pm \
	objc.pm \
	ode.pm \
	open_exlock.pm \
	opengl.pm \
	openjpeg.pm \
	pcre.pm \
	pctr.pm \
	percgi.pm \
	perl.pm \
	plutosvg.pm \
	png.pm \
	portaudio.pm \
	progname.pm \
	pthreads.pm \
	rand48.pm \
	sdl.pm \
	sdl2.pm \
	sdl_cpuinfo.pm \
	sdl_image.pm \
	sdl_ttf.pm \
	select.pm \
	setenv.pm \
	setjmp.pm \
	setlocale.pm \
	setproctitle.pm \
	shl_load.pm \
	signal.pm \
	siocgifconf.pm \
	smpeg.pm \
	sndfile.pm \
	snprintf.pm \
	so_peercred.pm \
	sockopts.pm \
	sse.pm \
	stdlib_h.pm \
	strlcat.pm \
	strlcpy.pm \
	strsep.pm \
	strtold.pm \
	strtoll.pm \
	sys_queue.pm \
	sys_stat.pm \
	sys_types.pm \
	syslog.pm \
	tcl.pm \
	tiff.pm \
	timerfd.pm \
	uim.pm \
	unistd_h.pm \
	vasprintf.pm \
	vsnprintf.pm \
	webp.pm \
	wgl.pm \
	winsock.pm \
	woa.pm \
	x11.pm \
	xbox.pm \
	xinerama.pm \
	zlib.pm \
	zstd.pm

all:

install:
	@if [ "${DESTDIR}" != "" ]; then \
		if [ ! -e "${DESTDIR}" ]; then \
			echo "${INSTALL_DESTDIR} ${DESTDIR}"; \
			${SUDO} ${INSTALL_DESTDIR} ${DESTDIR}; \
		fi; \
	fi; \
	if [ ! -e "${DESTDIR}${DATADIR}" ]; then \
		echo "${INSTALL_DATA_DIR} ${DATADIR}"; \
		${SUDO} ${INSTALL_DATA_DIR} ${DESTDIR}${DATADIR}; \
	fi; \
	if [ ! -d "${DESTDIR}${DATADIR}/BSDBuild" ]; then \
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

clean:

cleandir:

.PHONY: install

include ${TOP}/build.common.mk
include ${TOP}/build.subdir.mk
include ${TOP}/Makefile.config
