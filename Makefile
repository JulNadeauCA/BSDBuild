# $Csoft: Makefile,v 1.4 2002/07/27 06:33:00 vedge Exp $

TOP=.

SHARE=	csoft.common.mk csoft.dep.mk csoft.lib.mk csoft.man.mk \
	csoft.perl.mk csoft.prog.mk csoft.subdir.mk csoft.www.mk \
	hstrip.pl manuconf.pl maptree.sh mkdep mkify.pl

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
	rm -f Makefile.config configure *~

configure: .PHONY
	cat configure.in | ./manuconf.pl > configure
	chmod 755 configure

include ${TOP}/csoft.common.mk
include ${TOP}/csoft.subdir.mk
include ${TOP}/Makefile.config
