# $Csoft: csoft.www.mk,v 1.15 2003/06/25 02:49:40 vedge Exp $

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

M4?=		m4
XSLTPROC?=	xsltproc
PERL?=		perl
BASEDIR?=	m4
TEMPLATE?=	csoft
LANGUAGES?=	en fr
XSL?=		xsl/ml.xsl
MKDEPS=		csoft.www.mk csoft.subdir.mk csoft.common.mk hstrip.pl
HTMLDIR?=	none

.SUFFIXES: .html .htm .jpg .jpeg .png .gif .m4

.htm.html:
	@cp -f $< ${BASEDIR}/base.htm
	@echo -n "$@:"
	@for LANG in ${LANGUAGES}; do \
	    echo -n " $$LANG"; \
	    ${M4} -D__BASE_DIR=${BASEDIR} -D__FILE=$@ -D__LANG=$$LANG \
	        ${BASEDIR}/${TEMPLATE}.m4 \
		| ${PERL} ${TOP}/mk/hstrip.pl > $@.$$LANG.prep; \
            ${XSLTPROC} --html --nonet --stringparam lang $$LANG ${XSL} \
	        $@.$$LANG.prep > $@.$$LANG 2>/dev/null; \
	    rm -f $@.$$LANG.prep; \
	done; \
	rm -f ${BASEDIR}/base.htm; \
	echo "."

all: ${HTML} all-subdir

clean: clean-www clean-subdir

install: install-www install-subdir

deinstall: deinstall-www deinstall-subdir

depend: depend-subdir

clean-www:
	@for F in ${HTML}; do \
		echo "rm -f $$F"; \
		rm -f $$F; \
		for LANG in ${LANGUAGES}; do \
			echo "rm -f $$F.$$LANG"; \
			rm -f $$F.$$LANG; \
		done; \
	done

install-www: ${HTML}
	@if [ "${HTMLDIR}" = "none" ]; then \
		exit 0; \
	fi
	@for F in ${HTML}; do \
		rm -f $$F; \
        	if [ ! -d "${HTMLDIR}" ]; then \
			echo "${INSTALL_DATA_DIR} ${HTMLDIR}"; \
			${INSTALL_DATA_DIR} ${HTMLDIR}; \
		fi; \
        	if [ ! -d "${HTMLDIR}/mk" ]; then \
			echo "${INSTALL_DATA_DIR} ${HTMLDIR}/mk"; \
			${INSTALL_DATA_DIR} ${HTMLDIR}/mk; \
		fi; \
		for MK in ${MKDEPS}; do \
			echo "${INSTALL_DATA} ${TOP}/mk/$$MK ${HTMLDIR}/mk"; \
			${INSTALL_DATA} ${TOP}/mk/$$MK ${HTMLDIR}/mk; \
		done; \
        	if [ ! -d "${HTMLDIR}/xsl" ]; then \
			echo "${INSTALL_DATA_DIR} ${HTMLDIR}/xsl"; \
			${INSTALL_DATA_DIR} ${HTMLDIR}/xsl; \
		fi; \
		for XSL in ${XSL}; do \
			if [ -e ${HTMLDIR}/xsl/$$XSL ]; then \
				echo "xsl/$$XSL: exists; preserving"; \
			else \
				echo "${INSTALL_DATA} $$XSL ${HTMLDIR}/xsl"; \
				${INSTALL_DATA} $$XSL ${HTMLDIR}/xsl; \
			fi; \
		done; \
        	if [ ! -d "${HTMLDIR}/m4" ]; then \
			echo "${INSTALL_DATA_DIR} ${HTMLDIR}/m4"; \
			${INSTALL_DATA_DIR} ${HTMLDIR}/m4; \
		fi; \
		(cd m4; for M4IN in `ls -1 *.m4`; do \
			if [ -e ${HTMLDIR}/m4/$$M4IN ]; then \
				echo "m4/$$M4IN: exists; preserving"; \
			else \
				echo "${INSTALL_DATA} $$M4IN ${HTMLDIR}/m4"; \
				${INSTALL_DATA} $$M4IN ${HTMLDIR}/m4; \
			fi; \
		done); \
		if [ ! -e "${HTMLDIR}/Makefile" ]; then \
			echo "${INSTALL_DATA} /dev/null ${HTMLDIR}/Makefile"; \
			${INSTALL_DATA} /dev/null ${HTMLDIR}/Makefile; \
			echo "TOP=." > ${HTMLDIR}/Makefile; \
			echo "HTML=${HTML}" >> ${HTMLDIR}/Makefile; \
			echo "HTMLDIR=none" >> ${HTMLDIR}/Makefile; \
			echo "M4=${M4}" >> ${HTMLDIR}/Makefile; \
			echo "XSLTPROC=${XSLTPROC}" >> ${HTMLDIR}/Makefile; \
			echo "PERL=${PERL}" >> ${HTMLDIR}/Makefile; \
			echo "BASEDIR=${BASEDIR}" >> ${HTMLDIR}/Makefile; \
			echo "TEMPLATE=${TEMPLATE}" >> ${HTMLDIR}/Makefile; \
			echo "LANGUAGES=${LANGUAGES}" >> ${HTMLDIR}/Makefile; \
			echo "XSL=${XSL}" >> ${HTMLDIR}/Makefile; \
			echo "include mk/csoft.www.mk" >> ${HTMLDIR}/Makefile; \
		fi; \
		export SF=`echo $$F |sed s,.html$$,.htm,`; \
		if [ -e "${HTMLDIR}/$$SF" ]; then \
			echo "$$SF exists; preserving"; \
		else \
			echo "${INSTALL_DATA} $$SF ${HTMLDIR}"; \
			${INSTALL_DATA} $$SF ${HTMLDIR}; \
		fi; \
		for LANG in ${LANGUAGES}; do \
			if [ -e "${HTMLDIR}/$$F.$$LANG" ]; then \
				echo "$$F.$$LANG exists; preserving"; \
			else \
				echo "${INSTALL_DATA} $$F.$$LANG ${HTMLDIR}"; \
				${INSTALL_DATA} $$F.$$LANG ${HTMLDIR}; \
			fi; \
		done; \
	done

deinstall-www:
	@if [ "${HTMLDIR}" = "none" ]; then \
		exit 0; \
	fi
	for F in ${HTML}; do \
		echo "${DEINSTALL_DATA} ${HTMLDIR}/Makefile"; \
		${DEINSTALL_DATA} ${HTMLDIR}/Makefile; \
		echo "${DEINSTALL_DATA} ${HTMLDIR}/$$F"; \
		${DEINSTALL_DATA} ${HTMLDIR}/$$F; \
		export SF=`echo $$F |sed s,.html$$,.htm,`; \
		echo "${DEINSTALL_DATA} ${HTMLDIR}/$$SF"; \
		${DEINSTALL_DATA} ${HTMLDIR}/$$SF; \
		for LANG in ${LANGUAGES}; do \
			echo "${DEINSTALL_DATA} ${HTMLDIR}/$$F.$$LANG";\
			${DEINSTALL_DATA} ${HTMLDIR}/$$F.$$LANG; \
		done; \
		for MK in ${MKDEPS}; do \
			echo "${INSTALL_DATA} ${HTMLDIR}/mk/$$MK"; \
			${DEINSTALL_DATA} ${HTMLDIR}/mk/$$MK; \
		done; \
		for XSL in ${XSL}; do \
			echo "${DEINSTALL_DATA} ${HTMLDIR}/xsl/$$XSL"; \
			${DEINSTALL_DATA} ${HTMLDIR}/xsl/$$XSL; \
		done; \
		${DEINSTALL_DATA_DIR} ${HTMLDIR}/mk; \
		${DEINSTALL_DATA_DIR} ${HTMLDIR}/xsl; \
	done

regress: regress-subdir

include ${TOP}/mk/csoft.common.mk
include ${TOP}/mk/csoft.subdir.mk

.PHONY: clean depend install deinstall clean-www install-www deinstall-www
