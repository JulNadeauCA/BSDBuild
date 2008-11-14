TOP=.
include ${TOP}/Makefile.config

PROJECT=bsdbuild

SCRIPTS=mkconfigure \
	mkprojfiles \
	mkify \
	h2mandoc

SHARE=	hstrip.pl mkdep mkconcurrent.pl manlinks.pl cmpfiles.pl cleanfiles.pl \
	gen-includes.pl gen-declspecs.pl get-version.pl get-release.pl \
	install-manpages.sh ml.xsl \
	build.common.mk build.dep.mk build.lib.mk build.man.mk \
	build.perl.mk build.prog.mk build.subdir.mk build.www.mk \
	build.po.mk build.doc.mk build.den.mk build.proj.mk
	
LTFILES=config.guess config.sub configure configure.in ltconfig ltmain.sh

SUBDIR=	BSDBuild man

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

install: install-subdir
	@if [ ! -d "${SHAREDIR}" ]; then \
	    echo "${INSTALL_DATA_DIR} ${SHAREDIR}"; \
	    ${SUDO} ${INSTALL_DATA_DIR} "${SHAREDIR}"; \
	fi
	@if [ ! -d "${SHAREDIR}/libtool" ]; then \
	    echo "${INSTALL_DATA_DIR} ${SHAREDIR}/libtool"; \
	    ${SUDO} ${INSTALL_DATA_DIR} "${SHAREDIR}/libtool"; \
	fi
	@for F in ${SHARE}; do \
	    echo "${INSTALL_DATA} $$F ${SHAREDIR}"; \
	    ${SUDO} ${INSTALL_DATA} $$F "${SHAREDIR}"; \
	done
	@for F in ${LTFILES}; do \
	    echo "${INSTALL_DATA} libtool/$$F ${SHAREDIR}/libtool"; \
	    ${SUDO} ${INSTALL_DATA} libtool/$$F "${SHAREDIR}/libtool"; \
	done
	@for F in ${SCRIPTS}; do \
	    echo "${INSTALL_PROG} $$F ${BINDIR}"; \
	    ${SUDO} ${INSTALL_PROG} $$F "${BINDIR}"; \
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
	@if [ ! -d "${SHAREDIR}" ]; then \
	    echo "${INSTALL_DATA_DIR} ${SHAREDIR}"; \
	    ${SUDO} ${INSTALL_DATA_DIR} "${SHAREDIR}"; \
	fi
	@if [ ! -d "${SHAREDIR}/libtool" ]; then \
	    echo "${INSTALL_DATA_DIR} ${SHAREDIR}/libtool"; \
	    ${SUDO} ${INSTALL_DATA_DIR} "${SHAREDIR}/libtool"; \
	fi
	@for F in ${SHARE}; do \
	    echo "ln -sf `pwd`/$$F ${SHAREDIR}/$$F"; \
	    ${SUDO} ln -sf `pwd`/$$F "${SHAREDIR}/$$F"; \
	done
	@for F in ${LTFILES}; do \
	    echo "${INSTALL_DATA} libtool/$$F ${SHAREDIR}/libtool"; \
	    ${SUDO} ${INSTALL_DATA} libtool/$$F "${SHAREDIR}/libtool"; \
	done
	@for F in ${SCRIPTS}; do \
	    echo "${INSTALL_PROG} $$F.pl ${BINDIR}/$$F"; \
	    ${SUDO} ${INSTALL_PROG} $$F.pl "${BINDIR}"; \
	done

cleandir: cleandir-subdir
	echo > Makefile.config
	rm -fR config.log config configure.lua

clean: clean-subdir
	rm -f ${SCRIPTS}

configure: configure.in
	cat configure.in | perl mkconfigure.pl > configure
	chmod 755 configure

depend:
	# nothing

release:
	env VERSION="${VERSION}" RELEASE="${RELEASE}" sh mk/dist.sh stable

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
