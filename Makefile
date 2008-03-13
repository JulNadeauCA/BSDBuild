TOP=.

PROJECT=	bsdbuild
DIST=		${PROJECT}-${VERSION}
DISTFILE=	${DIST}.tar.gz

SHARE=	hstrip.pl mkdep mkify.pl mkconfigure.pl mkprojfiles.pl \
	mkconcurrent.pl manlinks.pl cmpfiles.pl \
	get-version.pl get-release.pl \
	build.common.mk build.dep.mk build.lib.mk build.man.mk \
	build.perl.mk build.prog.mk build.subdir.mk build.www.mk \
	build.po.mk build.doc.mk build.den.mk build.proj.mk
LTFILES=config.guess config.sub configure configure.in ltconfig ltmain.sh

SUBDIR=	BSDBuild man

all:	mkconfigure.out mkprojfiles.out mkify all-subdir

mkconfigure.out: mkconfigure.pl
	sed -e s,%PREFIX%,${PREFIX}, -e s,%VERSION%,${VERSION}, \
	    mkconfigure.pl > mkconfigure.out

mkprojfiles.out: mkprojfiles.pl
	sed -e s,%PREFIX%,${PREFIX}, -e s,%VERSION%,${VERSION}, \
	    mkprojfiles.pl > mkprojfiles.out

mkify: mkify.pl
	sed s,%PREFIX%,${PREFIX}, mkify.pl > mkify

install: install-subdir
	@if [ ! -d "${SHAREDIR}" ]; then \
	    echo "${INSTALL_DATA_DIR} ${SHAREDIR}"; \
	    ${SUDO} ${INSTALL_DATA_DIR} ${SHAREDIR}; \
	fi
	@if [ ! -d "${SHAREDIR}/libtool" ]; then \
	    echo "${INSTALL_DATA_DIR} ${SHAREDIR}/libtool"; \
	    ${SUDO} ${INSTALL_DATA_DIR} ${SHAREDIR}/libtool; \
	fi
	@for F in ${SHARE}; do \
	    echo "${INSTALL_DATA} $$F ${SHAREDIR}"; \
	    ${SUDO} ${INSTALL_DATA} $$F ${SHAREDIR}; \
	done
	@for F in ${LTFILES}; do \
	    echo "${INSTALL_DATA} libtool/$$F ${SHAREDIR}/libtool"; \
	    ${SUDO} ${INSTALL_DATA} libtool/$$F ${SHAREDIR}/libtool; \
	done
	${SUDO} ${INSTALL_PROG} mkify ${BINDIR}
	${SUDO} cp -f mkconfigure.out ${BINDIR}/mkconfigure
	${SUDO} chmod 755 ${BINDIR}/mkconfigure
	${SUDO} cp -f mkprojfiles.out ${BINDIR}/mkprojfiles
	${SUDO} chmod 755 ${BINDIR}/mkprojfiles

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
	    ${SUDO} ${INSTALL_DATA_DIR} ${SHAREDIR}; \
	fi
	@if [ ! -d "${SHAREDIR}/libtool" ]; then \
	    echo "${INSTALL_DATA_DIR} ${SHAREDIR}/libtool"; \
	    ${SUDO} ${INSTALL_DATA_DIR} ${SHAREDIR}/libtool; \
	fi
	@for F in ${SHARE}; do \
	    echo "ln -sf `pwd`/$$F ${SHAREDIR}/$$F"; \
	    ${SUDO} ln -sf `pwd`/$$F ${SHAREDIR}/$$F; \
	done
	@for F in ${LTFILES}; do \
	    echo "${INSTALL_DATA} libtool/$$F ${SHAREDIR}/libtool"; \
	    ${SUDO} ${INSTALL_DATA} libtool/$$F ${SHAREDIR}/libtool; \
	done
	${SUDO} ${INSTALL_PROG} mkify ${BINDIR}
	${SUDO} cp -f mkconfigure.out ${BINDIR}/mkconfigure
	${SUDO} chmod 755 ${BINDIR}/mkconfigure
	${SUDO} cp -f mkprojfiles.out ${BINDIR}/mkprojfiles
	${SUDO} chmod 755 ${BINDIR}/mkprojfiles

cleandir: cleandir-subdir
	rm -f Makefile.config config.log
	touch Makefile.config

clean: clean-subdir
	rm -f mkconfigure.out mkprojfiles.out mkify

configure: configure.in
	cat configure.in | perl mkconfigure.pl > configure
	chmod 755 configure

depend:
	# nothing

release: cleandir
	(cd .. && rm -fr ${DIST} && \
	 cp -fRp ${PROJECT} ${DIST} && \
	 rm -fr ${DIST}/CVS && \
	 tar -f ${DIST}.tar -c ${DIST} && \
	 gzip -9f ${DIST}.tar && \
	 md5sum ${DISTFILE} > ${DISTFILE}.md5 && \
	 sha1sum ${DISTFILE} >> ${DISTFILE}.md5 && \
	 gpg -ab ${DISTFILE} && \
	 scp ${DISTFILE} ${DISTFILE}.md5 ${DISTFILE}.asc \
	 vedge@resin:www/stable.csoft.org/${PROJECT})
	echo "TODO: Update sourceforge"
	echo "TODO: Update freshmeat"

.PHONY: install install-links install-links-subdir cleandir clean depend release

include ${TOP}/Makefile.config
include ${TOP}/mk/build.common.mk
include ${TOP}/mk/build.subdir.mk
