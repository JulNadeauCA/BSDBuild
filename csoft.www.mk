# $Csoft: csoft.www.mk,v 1.4 2001/12/04 16:53:19 vedge Exp $

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

DOCROOT?=	./docroot
M4?=		m4
SED?=		sed
PERL?=		perl
M4FLAGS?=
INSTALL?=	install
HTMLMODE?=	644

BASEDIR?=	${TOP}/base
TEMPLATE?=	fancy sober
DEFTMPL?=	sober

.SUFFIXES: .html .htm .jpg .jpeg .png .gif .m4

.htm.html:
	@for TMPL in ${TEMPLATE}; do					\
	    echo "===> $$TMPL-$@";					\
	    cp -f $< ${BASEDIR}/base.htm;				\
	    ${M4} ${M4FLAGS} -D_TMPL_=$$TMPL				\
		-D_TOP_=${TOP} -D_BASE_=${BASEDIR} -D_FILE_=$@		\
		${BASEDIR}/$$TMPL.m4 | ${PERL} ${TOP}/mk/hstrip.pl $@	\
		> $$TMPL-$@;						\
	done
	@cp -f ${DEFTMPL}-$@ $@

all: ${HTML} all-subdir

clean: clean-subdir
	@rm -f ${HTML} *.html

depend: depend-subdir

install: install-subdir ${HTML}
	@if [ "${HTML}" != "" ]; then					\
	    ${INSTALL} ${INSTALL_COPY} ${INSTALL_STRIP}			\
	    ${BINOWN} ${BINGRP} -m ${HTMLMODE} ${HTML} ${DOCROOT};	\
	fi
	
uninstall: uninstall-subdir
	@if [ "${HTML}" != "" ]; then	\
	    @for DOC in ${HTML}; do	\
		rm -f ${DOCROOT}/$$DOC;	\
	    done;			\
	fi

regress: regress-subdir

include ${TOP}/mk/csoft.common.mk
include ${TOP}/mk/csoft.subdir.mk
