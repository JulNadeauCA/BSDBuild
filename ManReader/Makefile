TOP=..

DATAFILES=	Mdoc.pm

all:

install:
	@if [ "${DESTDIR}" != "" ]; then \
		if [ ! -e "${DESTDIR}" ]; then \
			echo "${INSTALL_DESTDIR} ${DESTDIR}"; \
			${INSTALL_DESTDIR} ${DESTDIR}; \
		fi; \
	fi; \
	if [ ! -d "${DESTDIR}${DATADIR}/ManReader" ]; then \
	    echo "${INSTALL_DATA_DIR} ${DESTDIR}${DATADIR}/ManReader"; \
	    ${SUDO} ${INSTALL_DATA_DIR} ${DESTDIR}${DATADIR}/ManReader; \
	fi
	@for F in ${DATAFILES}; do \
	    echo "${INSTALL_DATA} $$F ${DESTDIR}${DATADIR}/ManReader"; \
	    ${SUDO} ${INSTALL_DATA} $$F ${DESTDIR}${DATADIR}/ManReader; \
	done

deinstall:
	@for F in ${DATAFILES}; do \
	    echo "${DEINSTALL_DATA} ${DESTDIR}${DATADIR}/ManReader/$$F"; \
	    ${SUDO} ${DEINSTALL_DATA} ${DESTDIR}${DATADIR}/ManReader/$$F; \
	done

install-links:
	@if [ ! -d "${DESTDIR}${DATADIR}/ManReader" ]; then \
	    echo "${INSTALL_DATA_DIR} ${DESTDIR}${DATADIR}/ManReader"; \
	    ${SUDO} ${INSTALL_DATA_DIR} ${DESTDIR}${DATADIR}/ManReader; \
	fi; \
	for F in ${DATAFILES}; do \
	    echo "ln -sf `pwd`/$$F ${DESTDIR}${DATADIR}/ManReader/$$F"; \
	    ${SUDO} ln -sf `pwd`/$$F ${DESTDIR}${DATADIR}/ManReader/$$F; \
	done

clean:

cleandir:

.PHONY: install install-links

include ${TOP}/build.common.mk
include ${TOP}/build.subdir.mk
include ${TOP}/Makefile.config
