# $Csoft: Makefile,v 1.1 2002/05/10 23:07:36 vedge Exp $

TOP=..

SHARE=	Core.pm \
	cc.pm glib.pm sdl.pm smpeg.pm x11.pm

all:

install:
	@if [ ! -d "${SHAREDIR}/Manuconf" ]; then \
	    echo "${INSTALL_DATA_DIR} ${SHAREDIR}/Manuconf"; \
	    ${INSTALL_DATA_DIR} ${SHAREDIR}/Manuconf; \
	fi; \
	for F in ${SHARE}; do \
	    echo "${INSTALL_DATA} $$F ${SHAREDIR}/Manuconf"; \
	    ${INSTALL_DATA} $$F ${SHAREDIR}/Manuconf; \
	done

cleandir:
	rm -f *~

include ${TOP}/csoft.common.mk
include ${TOP}/csoft.subdir.mk
include ${TOP}/Makefile.config
