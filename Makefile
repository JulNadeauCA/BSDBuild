# $Csoft: Makefile,v 1.23 2004/03/10 13:43:34 vedge Exp $

TOP=.

VERSION=	2.0
PROJECT=	csoft-mk
DIST=		${PROJECT}-${VERSION}
DISTFILE=	${DIST}.tar.gz

MAN5=	csoft.common.mk.5

SHARE=	csoft.common.mk csoft.dep.mk csoft.lib.mk csoft.man.mk \
	csoft.perl.mk csoft.prog.mk csoft.subdir.mk csoft.www.mk \
	hstrip.pl manuconf.pl mkdep mkify.pl mkconcurrent.pl csoft.po.mk \
	csoft.doc.mk csoft.den.mk

LTFILES=config.guess config.sub configure configure.in ltconfig ltmain.sh

SUBDIR=	Manuconf

all:	.tmp/manuconf mkify all-subdir

.tmp/manuconf: manuconf.pl
	mkdir .tmp
	sed -e s,%PREFIX%,${PREFIX}, -e s,%VERSION%,${VERSION}, \
	    manuconf.pl > .tmp/manuconf

mkify: mkify.pl
	sed s,%PREFIX%,${PREFIX}, mkify.pl > mkify

install: install-subdir
	@if [ ! -d "${SHAREDIR}" ]; then \
	    echo "${INSTALL_DATA_DIR} ${SHAREDIR}"; \
	    ${INSTALL_DATA_DIR} ${SHAREDIR}; \
	fi
	@if [ ! -d "${SHAREDIR}/libtool" ]; then \
	    echo "${INSTALL_DATA_DIR} ${SHAREDIR}/libtool"; \
	    ${INSTALL_DATA_DIR} ${SHAREDIR}/libtool; \
	fi
	@for F in ${SHARE}; do \
	    echo "${INSTALL_DATA} $$F ${SHAREDIR}"; \
	    ${INSTALL_DATA} $$F ${SHAREDIR}; \
	done
	@for F in ${LTFILES}; do \
	    echo "${INSTALL_DATA} libtool/$$F ${SHAREDIR}/libtool"; \
	    ${INSTALL_DATA} libtool/$$F ${SHAREDIR}/libtool; \
	done
	${INSTALL_PROG} .tmp/manuconf ${BINDIR}
	${INSTALL_PROG} mkify ${BINDIR}

cleandir:
	rm -f Makefile.config config.log *~

clean:
	rm -f manuconf mkify
	rm -fr .tmp

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
