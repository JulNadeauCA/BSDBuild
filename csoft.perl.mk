# $Csoft: csoft.perl.mk,v 1.10 2002/09/06 00:58:47 vedge Exp $

# Copyright (c) 2001, 2002 CubeSoft Communications, Inc. <http://www.csoft.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistribution of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Neither the name of CubeSoft Communications, nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
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

.SUFFIXES:  .pl .pm

PERL?=		/usr/bin/perl

SCRIPTS?=
MODULES?=
SHARE?=

SCRIPTS_DIR?=	${INST_BINDIR}
MODULES_DIR?=	${SHAREDIR}/perl

SCRIPTS_SUBST?=
MODULES_SUBST?=

all: all-subdir

install: install-subdir
	if [ "${SCRIPTS}" != "" ]; then \
	    if [ ! -d "${SCRIPTS_DIR}" ]; then \
	        echo "${INSTALL_PROG_DIR} ${SCRIPTS_DIR}"; \
	        ${INSTALL_PROG_DIR} ${SCRIPTS_DIR}; \
	    fi; \
	    if [ "${SCRIPTS_SUBST}" != "" ]; then \
		    for F in ${SCRIPTS}; do \
		        echo "sed -e '${SCRIPTS_SUBST}' $$F > ${SCRIPTS_DIR}/$$F"; \
		        sed -e '${SCRIPTS_SUBST}' $$F > ${SCRIPTS_DIR}/$$F; \
			chmod 555 ${SCRIPTS_DIR}/$$F; \
		    done; \
	    else \
		for F in ${SCRIPTS}; do \
		    echo "${INSTALL_PROG} $$F ${SCRIPTS_DIR}"; \
		    ${INSTALL_PROG} $$F ${SCRIPTS_DIR}; \
		done; \
	    fi; \
	fi
	@if [ "${MODULES}" != "" ]; then \
	    if [ ! -d "${MODULES_DIR}" ]; then \
	        echo "${INSTALL_DATA_DIR} ${MODULES_DIR}"; \
	        ${INSTALL_DATA_DIR} ${MODULES_DIR}; \
	    fi; \
	    if [ "${MODULES_SUBST}" != "" ]; then \
		    for F in ${MODULES}; do \
		        echo "sed -e '${MODULES_SUBST}' $$F > ${MODULES_DIR}/$$F"; \
		        sed -e '${MODULES_SUBST}' $$F > ${MODULES_DIR}/$$F; \
			chmod 444 ${SCRIPTS_DIR}/$$F; \
		    done; \
	    else \
	        for F in ${MODULES}; do \
	            echo "${INSTALL_DATA} $$F ${MODULES_DIR}"; \
	            ${INSTALL_DATA} $$F ${MODULES_DIR}; \
	        done; \
	    fi; \
	fi
	@export _share="${SHARE}"; \
        if [ "$$_share" != "" ]; then \
            if [ ! -d "${SHAREDIR}" ]; then \
                echo "${INSTALL_DATA_DIR} ${SHAREDIR}"; \
                ${INSTALL_DATA_DIR} ${SHAREDIR}; \
            fi; \
            for F in $$_share; do \
                echo "${INSTALL_DATA} $$F ${SHAREDIR}"; \
                ${INSTALL_DATA} $$F ${SHAREDIR}; \
            done; \
	fi

deinstall: deinstall-subdir
	@if [ "${SCRIPTS}" != "" ]; then \
	    for F in ${SCRIPTS}; do \
	        echo "${DEINSTALL_PROG} ${SCRIPTS_DIR}/$$F"; \
	        ${DEINSTALL_PROG} ${SCRIPTS_DIR}/$$F; \
	    done; \
	fi
	@if [ "${MODULES}" != "" ]; then \
	    for F in ${MODULES}; do \
	        echo "${DEINSTALL_DATA} ${MODULES_DIR}/$$F"; \
	        ${DEINSTALL_DATA} ${MODULES_DIR}/$$F; \
	    done; \
	fi
	@if [ "${SHARE}" != "" ]; then \
	    for F in ${SHARE}; do \
	        echo "${DEINSTALL_DATA} ${SHAREDIR}/$$F"; \
	        ${DEINSTALL_DATA} ${SHAREDIR}/$$F; \
	    done; \
	fi

clean: clean-subdir
	@if [ "${CLEANFILES}" != "" ]; then \
	    echo "rm -f ${CLEANFILES}"; \
	    rm -f ${CLEANFILES}; \
	fi

depend: depend-subdir

regress: regress-subdir

include ${TOP}/mk/csoft.common.mk
include ${TOP}/mk/csoft.subdir.mk
