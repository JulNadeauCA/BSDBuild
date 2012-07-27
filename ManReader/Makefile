TOP=..

DATAFILES=	Mdoc.pm

all:

install:
	@if [ ! -d "${DATADIR}/ManReader" ]; then \
	    echo "${INSTALL_DATA_DIR} ${DATADIR}/ManReader"; \
	    ${SUDO} ${INSTALL_DATA_DIR} ${DATADIR}/ManReader; \
	fi; \
	for F in ${DATAFILES}; do \
	    echo "${INSTALL_DATA} $$F ${DATADIR}/ManReader"; \
	    ${SUDO} ${INSTALL_DATA} $$F ${DATADIR}/ManReader; \
	done

install-links:
	@if [ ! -d "${DATADIR}/ManReader" ]; then \
	    echo "${INSTALL_DATA_DIR} ${DATADIR}/ManReader"; \
	    ${SUDO} ${INSTALL_DATA_DIR} ${DATADIR}/ManReader; \
	fi; \
	for F in ${DATAFILES}; do \
	    echo "ln -sf `pwd`/$$F ${DATADIR}/ManReader/$$F"; \
	    ${SUDO} ln -sf `pwd`/$$F ${DATADIR}/ManReader/$$F; \
	done

clean:

cleandir:

.PHONY: install install-links

include ${TOP}/build.common.mk
include ${TOP}/build.subdir.mk
include ${TOP}/Makefile.config
