# $Csoft: csoft.man.mk,v 1.7 2002/01/26 01:20:27 vedge Exp $

# Copyright (c) 2001 CubeSoft Communications, Inc.
# <http://www.csoft.org>
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistribution of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistribution in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of CubeSoft Communications, nor the names of its
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

CENTER?=	documentation
RELEASE?=	1.0

NROFF?=		nroff -Tascii
TBL?=		tbl

MANMODE?=	644
POD2MAN?=	pod2man

MANS=		${MAN1} ${MAN2} ${MAN3} ${MAN4} ${MAN5} ${MAN6} ${MAN7} ${MAN8}

.SUFFIXES:  .1 .2 .3 .4 .5 .6 .7 .8 .pod

.pod.1 .pod.2 .pod.3 .pod.4 .pod.5 .pod.6 .pod.7 .pod.8:
	${POD2MAN} '--center=${CENTER}' '--release=${RELEASE}' $< > $@

all: all-subdirs ${MANS}

clean: clean-subdir

depend: depend-subdir

install: install-subdir ${MANS}
	@if [ "${MAN1}" != "" ]; then \
	    echo "${INSTALL_DATA} ${MAN1} ${INST_MANDIR}/man1"; \
	    ${INSTALL_DATA} ${MAN1} ${INST_MANDIR}/man1; \
	fi
	@if [ "${MAN2}" != "" ]; then \
	    echo "${INSTALL_DATA} ${MAN2} ${INST_MANDIR}/man2"; \
	    ${INSTALL_DATA} ${MAN2} ${INST_MANDIR}/man1; \
	fi
	@if [ "${MAN3}" != "" ]; then \
	    echo "${INSTALL_DATA} ${MAN3} ${INST_MANDIR}/man3"; \
	    ${INSTALL_DATA} ${MAN3} ${INST_MANDIR}/man1; \
	fi
	@if [ "${MAN4}" != "" ]; then \
	    echo "${INSTALL_DATA} ${MAN4} ${INST_MANDIR}/man4"; \
	    ${INSTALL_DATA} ${MAN4} ${INST_MANDIR}/man1; \
	fi
	@if [ "${MAN5}" != "" ]; then \
	    echo "${INSTALL_DATA} ${MAN5} ${INST_MANDIR}/man5"; \
	    ${INSTALL_DATA} ${MAN5} ${INST_MANDIR}/man1; \
	fi
	@if [ "${MAN6}" != "" ]; then \
	    echo "${INSTALL_DATA} ${MAN6} ${INST_MANDIR}/man6"; \
	    ${INSTALL_DATA} ${MAN6} ${INST_MANDIR}/man1; \
	fi
	@if [ "${MAN7}" != "" ]; then \
	    echo "${INSTALL_DATA} ${MAN7} ${INST_MANDIR}/man7"; \
	    ${INSTALL_DATA} ${MAN7} ${INST_MANDIR}/man1; \
	fi
	@if [ "${MAN8}" != "" ]; then \
	    echo "${INSTALL_DATA} ${MAN8} ${INST_MANDIR}/man8"; \
	    ${INSTALL_DATA} ${MAN8} ${INST_MANDIR}/man1; \
	fi
	
deinstall: deinstall-subdir
	@if [ "${MAN1}" != "" ]; then \
	    (cd ${PREFIX}/man/man1 && echo "${DEINSTALL_DATA} ${MAN1}"; \
	        ${DEINSTALL_DATA} ${MAN1}); \
	fi
	@if [ "${MAN2}" != "" ]; then \
	    (cd ${PREFIX}/man/man2 && echo "${DEINSTALL_DATA} ${MAN2}"; \
	        ${DEINSTALL_DATA} ${MAN2}); \
	fi
	@if [ "${MAN3}" != "" ]; then \
	    (cd ${PREFIX}/man/man3 && echo "${DEINSTALL_DATA} ${MAN3}"; \
	        ${DEINSTALL_DATA} ${MAN3}); \
	fi
	@if [ "${MAN4}" != "" ]; then \
	    (cd ${PREFIX}/man/man4 && echo "${DEINSTALL_DATA} ${MAN4}"; \
	        ${DEINSTALL_DATA} ${MAN4}); \
	fi
	@if [ "${MAN5}" != "" ]; then \
	    (cd ${PREFIX}/man/man5 && echo "${DEINSTALL_DATA} ${MAN5}"; \
	        ${DEINSTALL_DATA} ${MAN5}); \
	fi
	@if [ "${MAN6}" != "" ]; then \
	    (cd ${PREFIX}/man/man6 && echo "${DEINSTALL_DATA} ${MAN6}"; \
	        ${DEINSTALL_DATA} ${MAN6}); \
	fi
	@if [ "${MAN7}" != "" ]; then \
	    (cd ${PREFIX}/man/man7 && echo "${DEINSTALL_DATA} ${MAN7}"; \
	        ${DEINSTALL_DATA} ${MAN7}); \
	fi
	@if [ "${MAN8}" != "" ]; then \
	    (cd ${PREFIX}/man/man8 && echo "${DEINSTALL_DATA} ${MAN8}"; \
	        ${DEINSTALL_DATA} ${MAN8}); \
	fi

regress: regress-subdir

include ${TOP}/mk/csoft.common.mk
include ${TOP}/mk/csoft.subdir.mk
