# $Csoft: csoft.www.mk,v 1.11 2002/09/06 00:58:47 vedge Exp $

# Copyright (c) 2001, 2002, 2003 CubeSoft Communications, Inc.
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

include ${TOP}/Makefile.inc

DOCROOT?=	./docroot
M4?=		m4
PERL?=		perl
M4FLAGS?=

BASEDIR?=	${TOP}/base
TEMPLATES?=	text
DEFAULT_TMPL?=	text

.SUFFIXES: .html .htm .jpg .jpeg .png .gif .m4

.htm.html:
	@for F in ${TEMPLATES}; do \
	    echo "${M4} ${M4FLAGS} -D_TMPL_=$$F	\
		-D_TOP_=${TOP} -D_BASE_=${BASEDIR} -D_FILE_=$@ \
		${BASEDIR}/$$F.m4"; \
	    cp -f $< ${BASEDIR}/base.htm; \
	    ${M4} ${M4FLAGS} -D_TMPL_=$$F \
		-D_TOP_=${TOP} -D_BASE_=${BASEDIR} -D_FILE_=$@ \
		${BASEDIR}/$$F.m4 > $$F-$@; \
	done
	@cp -f ${DEFAULT_TMPL}-$@ $@

all: ${HTML} all-subdir

clean: clean-subdir
	@if [ "${HTML}" != "" ]; then \
	    echo "rm -f *.html"; \
	    rm -f *.html; \
	fi

cleandir: cleandir-subdir
	rm -f *~

depend: depend-subdir

install: install-subdir ${HTML}
	@if [ "${HTML}" != "" ]; then \
	    echo "${INSTALL_DATA} ${HTML} ${DOCROOT}"; \
	    ${INSTALL_DATA} ${HTML} ${DOCROOT}; \
	fi
	
deinstall: deinstall-subdir
	@for F in ${HTML}; do \
	    echo "rm -f ${DOCROOT}/$$F"; \
	    rm -f ${DOCROOT}/$$F; \
	done

regress: regress-subdir

.PHONY: clean cleandir depend install deinstall regress

include ${TOP}/mk/csoft.common.mk
include ${TOP}/mk/csoft.subdir.mk
