# $Csoft: Makefile,v 1.8 2002/09/19 22:12:26 vedge Exp $

TOP=.

VERSION=	1.0
PROJECT=	csoft-mk
DIST=		${PROJECT}-${VERSION}
DISTFILE=	${DIST}.tar.gz

SHARE=	csoft.common.mk csoft.dep.mk csoft.lib.mk csoft.man.mk \
	csoft.perl.mk csoft.prog.mk csoft.subdir.mk csoft.www.mk \
	hstrip.pl manuconf.pl maptree.sh mkdep mkify.pl mkconcurrent.pl

SUBDIR=	Manuconf

all:	all-subdir

install: install-subdir
	@if [ ! -d "${SHAREDIR}" ]; then \
	    echo "${INSTALL_DATA_DIR} ${SHAREDIR}"; \
	    ${INSTALL_DATA_DIR} ${SHAREDIR}; \
	fi; \
	for F in ${SHARE}; do \
	    echo "${INSTALL_DATA} $$F ${SHAREDIR}"; \
	    ${INSTALL_DATA} $$F ${SHAREDIR}; \
	done
	sed s,%PREFIX%,${PREFIX}, manuconf.pl > ${INST_BINDIR}/manuconf
	chmod 555 ${INST_BINDIR}/manuconf
	sed s,%INSTALLDIR%,${SHAREDIR}, mkify.pl > ${INST_BINDIR}/mkify
	chmod 555 ${INST_BINDIR}/mkify

cleandir:
	rm -f Makefile.config config.log *~

clean:
	# nothing

configure: .PHONY
	cat configure.in | ./manuconf.pl > configure
	chmod 755 configure

depend:
	# nothing

release: cleandir
	(cd .. && rm -fr ${DIST} && \
	 cp -fRp ${PROJECT} ${DIST} && \
	 rm -fr ${DIST}/CVS && \
	 tar -f ${DIST}.tar -c ${DIST} && \
	 gzip -9f ${DIST}.tar && \
	 md5 ${DISTFILE} > ${DISTFILE}.md5 && \
	 rmd160 ${DISTFILE} >> ${DISTFILE}.md5 && \
	 sha1 ${DISTFILE} >> ${DISTFILE}.md5 && \
	 scp ${DISTFILE} \
	     ${DISTFILE}.md5 vedge@resin:www/stable.csoft.org/${PROJECT})

include ${TOP}/csoft.common.mk
include ${TOP}/csoft.subdir.mk
include ${TOP}/Makefile.config
