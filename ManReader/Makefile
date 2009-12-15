TOP=..

SHARE=	Mdoc.pm

all:

install:
	@if [ ! -d "${SHAREDIR}/ManReader" ]; then \
	    echo "${INSTALL_DATA_DIR} ${SHAREDIR}/ManReader"; \
	    ${SUDO} ${INSTALL_DATA_DIR} ${SHAREDIR}/ManReader; \
	fi; \
	for F in ${SHARE}; do \
	    echo "${INSTALL_DATA} $$F ${SHAREDIR}/ManReader"; \
	    ${SUDO} ${INSTALL_DATA} $$F ${SHAREDIR}/ManReader; \
	done

install-links:
	@if [ ! -d "${SHAREDIR}/ManReader" ]; then \
	    echo "${INSTALL_DATA_DIR} ${SHAREDIR}/ManReader"; \
	    ${SUDO} ${INSTALL_DATA_DIR} ${SHAREDIR}/ManReader; \
	fi; \
	for F in ${SHARE}; do \
	    echo "ln -sf `pwd`/$$F ${SHAREDIR}/ManReader/$$F"; \
	    ${SUDO} ln -sf `pwd`/$$F ${SHAREDIR}/ManReader/$$F; \
	done

clean:

cleandir:

.PHONY: install install-links

include ${TOP}/build.common.mk
include ${TOP}/build.subdir.mk
include ${TOP}/Makefile.config
