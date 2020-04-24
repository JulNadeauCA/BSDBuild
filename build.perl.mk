#
# Copyright (c) 2001-2020 Julien Nadeau Carriere <vedge@csoft.net>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
# USE OF THIS SOFTWARE EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#
# Install Perl scripts and modules.
#

PERL?=/usr/bin/perl
SCRIPTS?=
MODULES?=
DATAFILES?=
MODULES_DIR?=${DATADIR}/perl
SCRIPTS_SUBST?=
MODULES_SUBST?=
CLEANFILES?=

all: all-subdir
install: all install-perl install-subdir
deinstall: deinstall-perl deinstall-subdir
clean: clean-perl clean-subdir
cleandir: clean-perl clean-subdir cleandir-subdir
regress: regress-subdir
depend: depend-subdir

install-perl:
	if [ "${SCRIPTS}" != "" ]; then \
	    if [ ! -d "${BINDIR}" ]; then \
	        echo "${INSTALL_PROG_DIR} ${BINDIR}"; \
	        ${SUDO} ${INSTALL_PROG_DIR} ${DESTDIR}${BINDIR}; \
	    fi; \
	    if [ "${SCRIPTS_SUBST}" != "" ]; then \
		    for F in ${SCRIPTS}; do \
		        echo "sed -e '${SCRIPTS_SUBST}' $$F > $$F.prep"; \
		        sed -e '${SCRIPTS_SUBST}' $$F > $$F.prep; \
			echo "${INSTALL_PROG} $$F.prep ${BINDIR}/$$F"; \
			${SUDO} ${INSTALL_PROG} $$F.prep ${DESTDIR}${BINDIR}/$$F; \
			rm -f $$F.prep; \
		    done; \
	    else \
		for F in ${SCRIPTS}; do \
		    echo "${INSTALL_PROG} $$F ${BINDIR}"; \
		    ${SUDO} ${INSTALL_PROG} $$F ${DESTDIR}${BINDIR}; \
		done; \
	    fi; \
	fi
	@if [ "${MODULES}" != "" ]; then \
	    if [ ! -d "${MODULES_DIR}" ]; then \
	        echo "${INSTALL_DATA_DIR} ${MODULES_DIR}"; \
	        ${SUDO} ${INSTALL_DATA_DIR} ${DESTDIR}${MODULES_DIR}; \
	    fi; \
	    if [ "${MODULES_SUBST}" != "" ]; then \
		    for F in ${MODULES}; do \
		        echo "sed -e '${MODULES_SUBST}' $$F > $$F.prep"; \
		        sed -e '${MODULES_SUBST}' $$F > $$F.prep; \
			echo "${INSTALL_DATA} $$F.prep ${MODULES_DIR}/$$F"; \
			${SUDO} ${INSTALL_DATA} $$F.prep ${DESTDIR}${MODULES_DIR}/$$F; \
			rm -f $$F.prep; \
		    done; \
	    else \
	        for F in ${MODULES}; do \
	            echo "${INSTALL_DATA} $$F ${MODULES_DIR}"; \
	            ${SUDO} ${INSTALL_DATA} $$F ${DESTDIR}${MODULES_DIR}; \
	        done; \
	    fi; \
	fi
	@export _datafiles="${DATAFILES}"; \
        if [ "$$_datafiles" != "" ]; then \
            if [ ! -d "${DATADIR}" ]; then \
                echo "${INSTALL_DATA_DIR} ${DATADIR}"; \
                ${SUDO} ${INSTALL_DATA_DIR} ${DESTDIR}${DATADIR}; \
            fi; \
            for F in $$_datafiles; do \
                echo "${INSTALL_DATA} $$F ${DATADIR}"; \
                ${SUDO} ${INSTALL_DATA} $$F ${DESTDIR}${DATADIR}; \
            done; \
	fi

deinstall-perl:
	@if [ "${SCRIPTS}" != "" ]; then \
	    for F in ${SCRIPTS}; do \
	        echo "${DEINSTALL_PROG} ${BINDIR}/$$F"; \
	        ${SUDO} ${DEINSTALL_PROG} ${DESTDIR}${BINDIR}/$$F; \
	    done; \
	fi
	@if [ "${MODULES}" != "" ]; then \
	    for F in ${MODULES}; do \
	        echo "${DEINSTALL_DATA} ${MODULES_DIR}/$$F"; \
	        ${SUDO} ${DEINSTALL_DATA} ${DESTDIR}${MODULES_DIR}/$$F; \
	    done; \
	fi
	@if [ "${DATAFILES}" != "" ]; then \
	    for F in ${DATAFILES}; do \
	        echo "${DEINSTALL_DATA} ${DATADIR}/$$F"; \
	        ${SUDO} ${DEINSTALL_DATA} ${DESTDIR}${DATADIR}/$$F; \
	    done; \
	fi

clean-perl:
	@if [ "${CLEANFILES}" != "" ]; then \
	    echo "rm -f ${CLEANFILES}"; \
	    rm -f ${CLEANFILES}; \
	fi

.PHONY: install deinstall clean cleandir regress depend
.PHONY: install-perl deinstall-perl clean-perl

include ${TOP}/mk/build.common.mk
include ${TOP}/mk/build.subdir.mk
