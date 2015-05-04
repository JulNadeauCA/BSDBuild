TOP=.
include ${TOP}/Makefile.config

PROJECT=bsdbuild

SUBDIR=	BSDBuild \
	ManReader \
	man

SCRIPTS=mkconfigure \
	mkprojfiles \
	mkify \
	h2mandoc \
	man2wiki \
	uman

DATAFILES=hstrip.pl mkdep mkconcurrent.pl manlinks.pl cmpfiles.pl cleanfiles.pl \
	gen-includes.pl gen-declspecs.pl get-version.pl get-release.pl \
	install-manpages.sh ml.xsl gen-dotdepend.pl config.guess \
	gen-includelinks.pl \
	build.common.mk build.dep.mk build.lib.mk build.man.mk \
	build.perl.mk build.prog.mk build.subdir.mk build.www.mk \
	build.po.mk build.doc.mk build.proj.mk

LTFILES=Makefile Makefile.in aclocal.m4 config.guess config.sub configure \
	configure.in install-sh ltmain.sh README
LTFILES_M4=libtool.m4 ltoptions.m4 ltsugar.m4 ltversion.m4 lt~obsolete.m4

all: all-subdir ${SCRIPTS}

config-ok:
	@if [ "${CONFIGURE_OK}" != "yes" ]; then \
	    echo "Please run ./configure first"; \
	    exit 1; \
	fi

mkconfigure: config-ok mkconfigure.pl
	sed -e s,%PREFIX%,${PREFIX}, \
	    -e s,%VERSION%,${VERSION}, \
	    mkconfigure.pl > mkconfigure

mkprojfiles: config-ok mkprojfiles.pl
	sed -e s,%PREFIX%,${PREFIX}, \
	    -e s,%VERSION%,${VERSION}, \
	    mkprojfiles.pl > mkprojfiles

mkify: config-ok mkify.pl
	sed -e s,%DATADIR%,${DATADIR}, \
	    -e s,%BINDIR%,${BINDIR}, \
	    mkify.pl > mkify

h2mandoc: config-ok h2mandoc.pl
	sed -e s,%VERSION%,${VERSION}, \
	    h2mandoc.pl > h2mandoc

man2wiki: config-ok man2wiki.pl
	sed -e s,%PREFIX%,${PREFIX}, \
	    -e s,%VERSION%,${VERSION}, \
	    man2wiki.pl > man2wiki

uman: config-ok uman.pl
	sed -e s,%PREFIX%,${PREFIX}, \
	    -e s,%VERSION%,${VERSION}, \
	    uman.pl > uman

install: all config-ok install-subdir
	@if [ ! -d "${DESTDIR}${DATADIR}" ]; then \
	    echo "${INSTALL_DATA_DIR} ${DATADIR}"; \
	    ${SUDO} ${INSTALL_DATA_DIR} "${DESTDIR}${DATADIR}"; \
	fi
	@if [ ! -d "${DESTDIR}${DATADIR}/libtool" ]; then \
	    echo "${INSTALL_DATA_DIR} ${DATADIR}/libtool"; \
	    ${SUDO} ${INSTALL_DATA_DIR} "${DESTDIR}${DATADIR}/libtool"; \
	fi
	@if [ ! -d "${DESTDIR}${DATADIR}/libtool/m4" ]; then \
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

cleandir: cleandir-subdir
	echo > Makefile.config
	rm -fR config.log config configure.lua

clean: clean-subdir
	rm -f ${SCRIPTS}

configure: configure.in
	cat configure.in | mkconfigure > configure
	chmod 755 configure

depend:
	# nothing

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

.PHONY: install cleandir clean depend release configure clean-release config-ok

include ${TOP}/mk/build.common.mk
include ${TOP}/mk/build.subdir.mk
