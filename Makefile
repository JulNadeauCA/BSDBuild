TOP=.
include ${TOP}/Makefile.config

PROJECT=bsdbuild

SUBDIR=	BSDBuild \
	ManReader \
	man \
	mlproc

SCRIPTS=	mkconfigure \
		mkprojfiles \
		mkify \
		h2mandoc \
		uman

DATAFILES=	build.common.mk \
		build.doc.mk \
		build.lib.mk \
		build.man.mk \
		build.perl.mk \
		build.po.mk \
		build.proj.mk \
		build.prog.mk \
		build.subdir.mk \
		build.www.mk \
		config.guess \
		cleanfiles.pl \
		cmpfiles.pl \
		mkdep \
		mkconcurrent.pl \
		manlinks.pl \
		gen-bundle.pl \
		gen-declspecs.pl \
		gen-dotdepend.pl \
		gen-includelinks.pl \
		gen-includes.pl \
		get-release.pl \
		gen-revision.sh \
		gen-wwwdepend.pl \
		get-version.pl

LTFILES=	Makefile Makefile.in aclocal.m4 config.guess config.sub \
		configure configure.in install-sh ltmain.sh README
LTFILES_M4=	libtool.m4 ltoptions.m4 ltsugar.m4 ltversion.m4 lt~obsolete.m4

PERL?=/usr/bin/perl

all: all-subdir all-scripts

config-ok:
	@if [ "${CONFIGURE_OK}" != "yes" ]; then \
	    echo "Please run ./configure first"; \
	    exit 1; \
	fi

all-scripts: config-ok
	@for F in ${SCRIPTS}; do \
	    echo "sed $$F.pl > $$F"; \
	    sed -e s,%PREFIX%,${PREFIX}, \
	        -e s,%VERSION%,${VERSION}, \
	        -e s,%PERL%,${PERL}, \
	        -e s,%DATADIR%,${DATADIR}, \
	        -e s,%BINDIR%,${BINDIR}, \
	        $$F.pl > $$F; \
	done

install: all install-subdir
	@if [ "${DESTDIR}" != "" ]; then \
		if [ ! -e "${DESTDIR}" ]; then \
			echo "${INSTALL_DESTDIR} ${DESTDIR}"; \
			${INSTALL_DESTDIR} ${DESTDIR}; \
		fi; \
	fi; \
	if [ ! -d "${DESTDIR}${DATADIR}" ]; then \
	    echo "${INSTALL_DATA_DIR} ${DATADIR}"; \
	    ${SUDO} ${INSTALL_DATA_DIR} "${DESTDIR}${DATADIR}"; \
	fi; \
	if [ ! -d "${DESTDIR}${DATADIR}/libtool" ]; then \
	    echo "${INSTALL_DATA_DIR} ${DATADIR}/libtool"; \
	    ${SUDO} ${INSTALL_DATA_DIR} "${DESTDIR}${DATADIR}/libtool"; \
	fi; \
	if [ ! -d "${DESTDIR}${DATADIR}/libtool/m4" ]; then \
	    echo "${INSTALL_DATA_DIR} ${DATADIR}/libtool/m4"; \
	    ${SUDO} ${INSTALL_DATA_DIR} "${DESTDIR}${DATADIR}/libtool/m4"; \
	fi
	@for F in ${DATAFILES}; do \
	    echo "${INSTALL_DATA} $$F ${DATADIR}"; \
	    ${SUDO} ${INSTALL_DATA} $$F "${DESTDIR}${DATADIR}"; \
	done
	@for F in ${LTFILES}; do \
	    echo "${INSTALL_DATA} libtool/$$F ${DATADIR}/libtool"; \
	    ${SUDO} ${INSTALL_DATA} libtool/$$F "${DESTDIR}${DATADIR}/libtool"; \
	done
	@for F in ${LTFILES_M4}; do \
	    echo "${INSTALL_DATA} libtool/m4/$$F ${DATADIR}/libtool/m4"; \
	    ${SUDO} ${INSTALL_DATA} libtool/m4/$$F "${DESTDIR}${DATADIR}/libtool/m4"; \
	done
	@if [ ! -d "${DESTDIR}${BINDIR}" ]; then \
	    echo "${INSTALL_PROG_DIR} ${BINDIR}"; \
	    ${SUDO} ${INSTALL_PROG_DIR} "${DESTDIR}${BINDIR}"; \
	fi
	@for F in ${SCRIPTS}; do \
	    echo "${INSTALL_PROG} $$F ${BINDIR}"; \
	    ${SUDO} ${INSTALL_PROG} $$F "${DESTDIR}${BINDIR}"; \
	done

deinstall: deinstall-subdir
	@for F in ${LTFILES_M4}; do \
	    echo "${DEINSTALL_DATA} ${DATADIR}/libtool/m4/$$F"; \
	    ${SUDO} ${DEINSTALL_DATA} "${DESTDIR}${DATADIR}/libtool/m4/$$F"; \
	done
	@for F in ${LTFILES}; do \
	    echo "${DEINSTALL_DATA} ${DATADIR}/libtool/$$F"; \
	    ${SUDO} ${DEINSTALL_DATA} "${DESTDIR}${DATADIR}/libtool/$$F"; \
	done
	@for F in ${DATAFILES}; do \
	    echo "${DEINSTALL_DATA} ${DATADIR}/$$F"; \
	    ${SUDO} ${DEINSTALL_DATA} "${DESTDIR}${DATADIR}/$$F"; \
	done
	@for F in ${SCRIPTS}; do \
	    echo "${DEINSTALL_DATA} ${BINDIR}/$$F"; \
	    ${SUDO} ${DEINSTALL_DATA} "${DESTDIR}${BINDIR}/$$F"; \
	done

cleandir: cleandir-subdir
	echo > Makefile.config
	rm -fR config.log config configure.lua

clean: clean-subdir
	rm -f ${SCRIPTS}

configure: configure.in
	cat configure.in | mkconfigure > configure
	chmod 755 configure

depend:

release:
	env VERSION=`perl get-version.pl` RELEASE="`perl get-release.pl`" \
	  sh mk/dist.sh stable

clean-release:
	@(export VERSION=`perl get-version.pl`; \
	  echo "rm -fR ../${PROJECT}-${VERSION}"; \
	  rm -fR ../${PROJECT}-${VERSION}; \
	  for F in ${PROJECT}-${VERSION}.tar.gz* ${PROJECT}-${VERSION}.zip*; do \
		echo "rm -f ../$$F"; \
		rm -f ../$$F; \
	  done);

.PHONY: install deinstall cleandir clean depend release configure clean-release
.PHONY: config-ok

include ${TOP}/mk/build.common.mk
include ${TOP}/mk/build.subdir.mk
