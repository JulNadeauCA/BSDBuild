# $Csoft: csoft.www.mk,v 1.1 2002/12/02 07:07:31 vedge Exp $

# Copyright (c) 2001, 2002, 2003 CubeSoft Communications, Inc.
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

DOCROOT?=	./docroot
M4?=		m4
XSLTPROC?=	xsltproc
PERL?=		perl

BASEDIR?=	${TOP}/base
TEMPLATE?=	black
LANGUAGES?=	en fr
MLXSL?=		${TOP}/xsl/ml.xsl

.SUFFIXES: .html .htm .jpg .jpeg .png .gif .m4

.htm.html:
	@cp -f $< ${BASEDIR}/base.htm
	@echo -n "$@:"
	@for LANG in ${LANGUAGES}; do \
	    echo -n " $$LANG"; \
	    ${M4} -D__BASE_DIR=${BASEDIR} -D__FILE=$@ -D__LANG=$$LANG \
	        ${BASEDIR}/${TEMPLATE}.m4 \
		| ${PERL} ${TOP}/mk/hstrip.pl > $@.$$LANG.prep; \
            ${XSLTPROC} --html --nonet --stringparam lang $$LANG ${MLXSL} \
	        $@.$$LANG.prep > $@.$$LANG 2>/dev/null; \
	    rm -f $@.$$LANG.prep; \
	done
	@echo "."

all: ${HTML} all-subdir

clean: clean-subdir
	@for F in ${HTML}; do \
		rm -f $$F; \
		for LANG in ${LANGUAGES}; do \
			rm -f $$F.$$LANG; \
		done; \
	done

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
	    echo "rm -f ${DOCROOT}/${TEMPLATE}"; \
	    rm -f ${DOCROOT}/${TEMPLATE}; \
	done

regress: regress-subdir

include ${TOP}/mk/csoft.common.mk
include ${TOP}/mk/csoft.subdir.mk

.PHONY: clean cleandir depend install deinstall regress
