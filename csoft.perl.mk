# $Csoft: csoft.perl.mk,v 1.15 2003/12/10 02:29:30 vedge Exp $

# Copyright (c) 2001, 2002, 2003, 2004 CubeSoft Communications, Inc.
# <http://www.csoft.org>
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

PERL?=	/usr/bin/perl
SCRIPTS?=
MODULES?=
SHARE?=
SCRIPTS_DIR?=	${INST_BINDIR}
MODULES_DIR?=	${SHAREDIR}/perl
SCRIPTS_SUBST?=
MODULES_SUBST?=

all: all-subdir
install: install-perl install-subdir
deinstall: deinstall-perl deinstall-subdir
clean: clean-perl clean-subdir
cleandir: clean-perl clean-subdir cleandir-subdir
regress: regress-subdir
depend: depend-subdir

install-perl:
	if [ "${SCRIPTS}" != "" ]; then \
	    if [ ! -d "${SCRIPTS_DIR}" ]; then \
	        echo "${INSTALL_PROG_DIR} ${SCRIPTS_DIR}"; \
	        ${SUDO} ${INSTALL_PROG_DIR} ${SCRIPTS_DIR}; \
	    fi; \
	    if [ "${SCRIPTS_SUBST}" != "" ]; then \
		    for F in ${SCRIPTS}; do \
		        echo "sed -e '${SCRIPTS_SUBST}' $$F > $$F.prep"; \
		        sed -e '${SCRIPTS_SUBST}' $$F > $$F.prep; \
			echo "${INSTALL_PROG} $$F.prep ${SCRIPTS_DIR}/$$F"; \
			${SUDO} ${INSTALL_PROG} $$F.prep ${SCRIPTS_DIR}/$$F; \
			rm -f $$F.prep; \
		    done; \
	    else \
		for F in ${SCRIPTS}; do \
		    echo "${INSTALL_PROG} $$F ${SCRIPTS_DIR}"; \
		    ${SUDO} ${INSTALL_PROG} $$F ${SCRIPTS_DIR}; \
		done; \
	    fi; \
	fi
	@if [ "${MODULES}" != "" ]; then \
	    if [ ! -d "${MODULES_DIR}" ]; then \
	        echo "${INSTALL_DATA_DIR} ${MODULES_DIR}"; \
	        ${SUDO} ${INSTALL_DATA_DIR} ${MODULES_DIR}; \
	    fi; \
	    if [ "${MODULES_SUBST}" != "" ]; then \
		    for F in ${MODULES}; do \
		        echo "sed -e '${MODULES_SUBST}' $$F > $$F.prep"; \
		        sed -e '${MODULES_SUBST}' $$F > $$F.prep; \
			echo "${INSTALL_DATA} $$F.prep ${MODULES_DIR}/$$F"; \
			${SUDO} ${INSTALL_DATA} $$F.prep ${MODULES_DIR}/$$F; \
			rm -f $$F.prep; \
		    done; \
	    else \
	        for F in ${MODULES}; do \
	            echo "${INSTALL_DATA} $$F ${MODULES_DIR}"; \
	            ${SUDO} ${INSTALL_DATA} $$F ${MODULES_DIR}; \
	        done; \
	    fi; \
	fi
	@export _share="${SHARE}"; \
        if [ "$$_share" != "" ]; then \
            if [ ! -d "${SHAREDIR}" ]; then \
                echo "${INSTALL_DATA_DIR} ${SHAREDIR}"; \
                ${SUDO} ${INSTALL_DATA_DIR} ${SHAREDIR}; \
            fi; \
            for F in $$_share; do \
                echo "${INSTALL_DATA} $$F ${SHAREDIR}"; \
                ${SUDO} ${INSTALL_DATA} $$F ${SHAREDIR}; \
            done; \
	fi

deinstall-perl:
	@if [ "${SCRIPTS}" != "" ]; then \
	    for F in ${SCRIPTS}; do \
	        echo "${DEINSTALL_PROG} ${SCRIPTS_DIR}/$$F"; \
	        ${SUDO} ${DEINSTALL_PROG} ${SCRIPTS_DIR}/$$F; \
	    done; \
	fi
	@if [ "${MODULES}" != "" ]; then \
	    for F in ${MODULES}; do \
	        echo "${DEINSTALL_DATA} ${MODULES_DIR}/$$F"; \
	        ${SUDO} ${DEINSTALL_DATA} ${MODULES_DIR}/$$F; \
	    done; \
	fi
	@if [ "${SHARE}" != "" ]; then \
	    for F in ${SHARE}; do \
	        echo "${DEINSTALL_DATA} ${SHAREDIR}/$$F"; \
	        ${SUDO} ${DEINSTALL_DATA} ${SHAREDIR}/$$F; \
	    done; \
	fi

clean-perl:
	@if [ "${CLEANFILES}" != "" ]; then \
	    echo "rm -f ${CLEANFILES}"; \
	    rm -f ${CLEANFILES}; \
	fi

.PHONY: install deinstall clean cleandir regress depend
.PHONY: install-perl deinstall-perl clean-perl

include ${TOP}/mk/csoft.common.mk
include ${TOP}/mk/csoft.subdir.mk
