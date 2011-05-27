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

SHARE=	hstrip.pl mkdep mkconcurrent.pl manlinks.pl cmpfiles.pl cleanfiles.pl \
	gen-includes.pl gen-declspecs.pl get-version.pl get-release.pl \
	install-manpages.sh ml.xsl gen-dotdepend.pl config.guess \
	gen-includelinks.pl \
	build.common.mk build.dep.mk build.lib.mk build.man.mk \
	build.perl.mk build.prog.mk build.subdir.mk build.www.mk \
	build.po.mk build.doc.mk build.den.mk build.proj.mk
	
LTFILES=config.guess config.sub configure configure.in ltconfig ltmain.sh

all: all-subdir ${SCRIPTS}

mkconfigure: mkconfigure.pl
	sed -e s,%PREFIX%,${PREFIX}, \
	    -e s,%VERSION%,${VERSION}, \
	    mkconfigure.pl > mkconfigure

mkprojfiles: mkprojfiles.pl
	sed -e s,%PREFIX%,${PREFIX}, \
	    -e s,%VERSION%,${VERSION}, \
	    mkprojfiles.pl > mkprojfiles

mkify: mkify.pl
	sed -e s,%SHAREDIR%,${SHAREDIR}, \
	    -e s,%BINDIR%,${BINDIR}, \
	    mkify.pl > mkify

h2mandoc: h2mandoc.pl
	sed -e s,%VERSION%,${VERSION}, \
	    h2mandoc.pl > h2mandoc

man2wiki: man2wiki.pl
	sed -e s,%PREFIX%,${PREFIX}, \
	    -e s,%VERSION%,${VERSION}, \
	    man2wiki.pl > man2wiki

uman: uman.pl
	sed -e s,%PREFIX%,${PREFIX}, \
	    -e s,%VERSION%,${VERSION}, \
	    uman.pl > uman

install: install-subdir
	@if [ ! -d "${DESTDIR}${SHAREDIR}" ]; then \
	    echo "${INSTALL_DATA_DIR} ${SHAREDIR}"; \
	    ${SUDO} ${INSTALL_DATA_DIR} "${DESTDIR}${SHAREDIR}"; \
	fi
	@if [ ! -d "${DESTDIR}${SHAREDIR}/libtool" ]; then \
	    echo "${INSTALL_DATA_DIR} ${SHAREDIR}/libtool"; \
	    ${SUDO} ${INSTALL_DATA_DIR} "${DESTDIR}${SHAREDIR}/libtool"; \
	fi
	@for F in ${SHARE}; do \
	    echo "${INSTALL_DATA} $$F ${SHAREDIR}"; \
	    ${SUDO} ${INSTALL_DATA} $$F "${DESTDIR}${SHAREDIR}"; \
	done
	@for F in ${LTFILES}; do \
	    echo "${INSTALL_DATA} libtool/$$F ${SHAREDIR}/libtool"; \
	    ${SUDO} ${INSTALL_DATA} libtool/$$F "${DESTDIR}${SHAREDIR}/libtool"; \
	done
	@for F in ${SCRIPTS}; do \
	    echo "${INSTALL_PROG} $$F ${BINDIR}"; \
	    ${SUDO} ${INSTALL_PROG} $$F "${DESTDIR}${BINDIR}"; \
	done

install-links-subdir:
	@(if [ "${SUBDIR}" = "" ]; then \
	    SUBDIR="NONE"; \
	else \
	    SUBDIR="${SUBDIR}"; \
	fi; \
	if [ "$$SUBDIR" != "" -a "$$SUBDIR" != "NONE" ]; then \
		for F in $$SUBDIR; do \
		    echo "==> ${REL}$$F"; \
		    (cd $$F && ${MAKE} REL=${REL}$$F/ install-links); \
		    if [ $$? != 0 ]; then \
		    	exit 1; \
		    fi; \
		done; \
	fi)

install-links: install-links-subdir
	@if [ ! -d "${DESTDIR}${SHAREDIR}" ]; then \
	    echo "${INSTALL_DATA_DIR} ${SHAREDIR}"; \
	    ${SUDO} ${INSTALL_DATA_DIR} "${DESTDIR}${SHAREDIR}"; \
	fi
	@if [ ! -d "${SHAREDIR}/libtool" ]; then \
	    echo "${INSTALL_DATA_DIR} ${SHAREDIR}/libtool"; \
	    ${SUDO} ${INSTALL_DATA_DIR} "${DESTDIR}${SHAREDIR}/libtool"; \
	fi
	@for F in ${SHARE}; do \
	    echo "ln -sf `pwd`/$$F ${SHAREDIR}/$$F"; \
	    ${SUDO} ln -sf `pwd`/$$F "${DESTDIR}${SHAREDIR}/$$F"; \
	done
	@for F in ${LTFILES}; do \
	    echo "${INSTALL_DATA} libtool/$$F ${SHAREDIR}/libtool"; \
	    ${SUDO} ${INSTALL_DATA} libtool/$$F "${DESTDIR}${SHAREDIR}/libtool"; \
	done
	@for F in ${SCRIPTS}; do \
	    echo "${INSTALL_PROG} $$F.pl ${BINDIR}/$$F"; \
	    ${SUDO} ${INSTALL_PROG} $$F.pl "${DESTDIR}${BINDIR}"; \
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

.PHONY: install install-links install-links-subdir cleandir clean depend release configure clean-release

include ${TOP}/mk/build.common.mk
include ${TOP}/mk/build.subdir.mk
