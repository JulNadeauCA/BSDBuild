# $Csoft: Makefile,v 1.19 2003/08/08 00:09:15 vedge Exp $

TOP=.

VERSION=	1.9
PROJECT=	csoft-mk
DIST=		${PROJECT}-${VERSION}
DISTFILE=	${DIST}.tar.gz

SHARE=	csoft.common.mk csoft.dep.mk csoft.lib.mk csoft.man.mk \
	csoft.perl.mk csoft.prog.mk csoft.subdir.mk csoft.www.mk \
	hstrip.pl manuconf.pl mkdep mkify.pl mkconcurrent.pl csoft.po.mk

SUBDIR=	Manuconf

all:	manuconf mkify all-subdir

manuconf: manuconf.pl
	sed -e s,%PREFIX%,${PREFIX}, -e s,%VERSION%,${VERSION}, \
	    manuconf.pl > manuconf

mkify: mkify.pl
	sed s,%PREFIX%,${PREFIX}, mkify.pl > mkify

install: install-subdir
	@if [ ! -d "${SHAREDIR}" ]; then \
	    echo "${INSTALL_DATA_DIR} ${SHAREDIR}"; \
	    ${INSTALL_DATA_DIR} ${SHAREDIR}; \
	fi; \
	for F in ${SHARE}; do \
	    echo "${INSTALL_DATA} $$F ${SHAREDIR}"; \
	    ${INSTALL_DATA} $$F ${SHAREDIR}; \
	done
	${INSTALL_PROG} manuconf ${INST_BINDIR}
	${INSTALL_PROG} mkify ${INST_BINDIR}

cleandir:
	rm -f Makefile.config config.log *~

clean:
	rm -f manuconf mkify

configure: configure.in
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
	 gpg -ab ${DISTFILE} && \
	 scp ${DISTFILE} ${DISTFILE}.md5 ${DISTFILE}.asc \
	 vedge@resin:www/stable.csoft.org/${PROJECT})

.PHONY: install cleandir clean depend release

include ${TOP}/csoft.common.mk
include ${TOP}/csoft.subdir.mk
include ${TOP}/Makefile.config
