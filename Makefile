# $Csoft: Makefile,v 1.1 2002/05/10 23:07:36 vedge Exp $

TOP=.

SHARE=	csoft.common.mk csoft.dep.mk csoft.lib.mk csoft.man.mk \
	csoft.perl.mk csoft.prog.mk csoft.subdir.mk csoft.www.mk \
	hstrip.pl manuconf.pl maptree.sh mkdep mkify.pl

SUBDIR=	Manuconf

all:	all-subdir

install:
	@if [ ! -d "${SHAREDIR}" ]; then \
	    echo "${INSTALL_DATA_DIR} ${SHAREDIR}"; \
	    ${INSTALL_DATA_DIR} ${SHAREDIR}; \
	fi; \
	for F in ${SHARE}; do \
	    echo "${INSTALL_DATA} $$F ${SHAREDIR}"; \
	    ${INSTALL_DATA} $$F ${SHAREDIR}; \
	done
	${INSTALL_PROG} manuconf.pl ${INST_BINDIR}/manuconf
	sed s,%INSTALLDIR%,${SHAREDIR}, mkify.pl > ${INST_BINDIR}/mkify

cleandir:
	rm -f Makefile.config configure *~

include ${TOP}/csoft.common.mk
include ${TOP}/csoft.subdir.mk
include ${TOP}/Makefile.config
