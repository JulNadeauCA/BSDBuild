# $Csoft$

TOP=.

SHARE=	csoft.common.mk csoft.dep.mk csoft.lib.mk csoft.man.mk \
	csoft.perl.mk csoft.prog.mk csoft.subdir.mk csoft.www.mk \
	hstrip.pl manuconf.pl maptree.sh mkdep mkify.pl

ALL:

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

include ${TOP}/csoft.common.mk
include ${TOP}/Makefile.config
