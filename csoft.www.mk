# $Csoft: csoft.www.mk,v 1.18 2003/09/26 12:29:25 vedge Exp $

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
ICONV?=		iconv
BASEDIR?=	m4
XSLDIR?=	xsl
TEMPLATE?=	csoft
LANGUAGES?=	en fr
XSL?=		${XSLDIR}/ml.xsl
MKDEPS=		csoft.www.mk csoft.subdir.mk csoft.common.mk hstrip.pl
HTMLDIR?=	none

all: ${HTML} all-subdir
clean: clean-www clean-subdir
cleandir: cleandir-subdir
install: install-www install-subdir
deinstall: deinstall-subdir
regress: regress-subdir
depend: depend-subdir

.SUFFIXES: .html .htm .jpg .jpeg .png .gif .m4

.htm.html:
	@cp -f $< ${BASEDIR}/base.htm
	@echo > $@.var
	@echo -n "$@:"
	@for LANG in ${LANGUAGES}; do \
	    echo -n " $$LANG"; \
	    ${M4} -D__BASE_DIR=${BASEDIR} -D__FILE=$@ -D__LANG=$$LANG \
	        ${BASEDIR}/${TEMPLATE}.m4 \
		| ${PERL} ${TOP}/mk/hstrip.pl > $@.$$LANG.prep; \
            ${XSLTPROC} --html --nonet --stringparam lang $$LANG ${XSL} \
	        $@.$$LANG.prep > $@.$$LANG.utf8 2>/dev/null; \
	    rm -f $@.$$LANG.prep; \
	    cp -f $@.$$LANG.utf8 $@.$$LANG; \
	    echo "URI: $@.$$LANG.utf8" >> $@.var; \
	    echo "Content-language: $$LANG" >> $@.var; \
	    echo "Content-type: text/html;encoding=UTF-8" >> $@.var; \
	    echo "" >> $@.var; \
	    echo "URI: $@.$$LANG" >> $@.var; \
	    echo "Content-language: $$LANG" >> $@.var; \
	    echo "Content-type: text/html;encoding=UTF-8" >> $@.var; \
	    echo "" >> $@.var; \
	    case "$$LANG" in \
	    ab|af|eu|ca|da|nl|en|fo|fr|fi|de|is|ga|it|no|nb|nn|pt|rm|gd|es|sv|sw) \
	        echo "URI: $@.$$LANG.iso8859-1" >> $@.var; \
	        echo "Content-language: $$LANG" >> $@.var; \
	        echo "Content-type: text/html;charset=ISO-8859-1" >> $@.var; \
	        echo "" >> $@.var; \
	        ${ICONV} -f UTF-8 -t ISO-8859-1 $@.$$LANG > \
		    $@.$$LANG.iso8859-1; \
		;; \
	    cs) \
	        echo "URI: $@.$$LANG.iso8859-2" >> $@.var; \
	        echo "Content-language: $$LANG" >> $@.var; \
	        echo "Content-type: text/html;charset=ISO-8859-2" >> $@.var; \
	        echo "" >> $@.var; \
	        ${ICONV} -f UTF-8 -t ISO-8859-2 $@.cz > $@.cz.iso8859-2; \
		;; \
	    he) \
	        echo "URI: $@.$$LANG.iso8859-8" >> $@.var; \
	        echo "Content-language: $$LANG" >> $@.var; \
	        echo "Content-type: text/html;charset=ISO-8859-8" >> $@.var; \
	        echo "" >> $@.var; \
	        ${ICONV} -f UTF-8 -t ISO-8859-8 $@.he > $@.he.iso8859-8; \
		;; \
	    hr) \
	        echo "URI: $@.$$LANG.iso8859-2" >> $@.var; \
	        echo "Content-language: $$LANG" >> $@.var; \
	        echo "Content-type: text/html;charset=ISO-8859-2" >> $@.var; \
	        echo "" >> $@.var; \
	        ${ICONV} -f UTF-8 -t ISO-8859-2 $@.hr > $@.hr.iso8859-2; \
		;; \
	    ja) \
	        echo "URI: $@.$$LANG.iso2022-jp" >> $@.var; \
	        echo "Content-language: $$LANG" >> $@.var; \
	        echo "Content-type: text/html;charset=ISO-2022-JP" >> $@.var; \
	        echo "" >> $@.var; \
	        ${ICONV} -f UTF-8 -t ISO-2022-JP $@ > $@.iso2022-jp; \
		;; \
	    ko) \
	        echo "URI: $@.$$LANG.euc-kr" >> $@.var; \
	        echo "Content-language: $$LANG" >> $@.var; \
	        echo "Content-type: text/html;charset=EUC-KR" >> $@.var; \
	        echo "" >> $@.var; \
	        ${ICONV} -f UTF-8 -t EUC-KR $@ > $@.euc-kr ; \
		;; \
	    po) \
	        echo "URI: $@.$$LANG.iso8859-2" >> $@.var; \
	        echo "Content-language: $$LANG" >> $@.var; \
	        echo "Content-type: text/html;charset=ISO-8859-2" >> $@.var; \
	        echo "" >> $@.var; \
	        ${ICONV} -f UTF-8 -t ISO-8859-2 $@ > $@.iso8859-2; \
		;; \
	    ru) \
	        echo "URI: $@.ru.cp1251" >> $@.var; \
	        echo "Content-language: ru" >> $@.var; \
	        echo "Content-type: text/html;charset=WINDOWS-1251" >> $@.var;\
		echo "" >> $@.var; \
		${ICONV} -f UTF-8 -t CP1251 $@ > $@.ru.cp1251; \
	        echo "URI: $@.ru.cp866" >> $@.var; \
	        echo "Content-language: ru" >> $@.var; \
	        echo "Content-type: text/html;charset=CP866" >> $@.var; \
	        echo "" >> $@.var; \
	        ${ICONV} -f UTF-8 -t CP866 $@ > $@.ru.cp866; \
	        echo "URI: $@.ru.iso-ru" >> $@.var; \
	        echo "Content-language: ru" >> $@.var; \
	        echo "Content-type: text/html;charset=ISO-8859-5" >> $@.var; \
		echo "" >> $@.var; \
	        ${ICONV} -f UTF-8 -t ISO-8859-5 $@ > $@.ru.iso-ru; \
	        echo "URI: $@.ru.koi8-r" >> $@.var; \
	        echo "Content-language: ru" >> $@.var; \
	        echo "Content-type: text/html;charset=KOI8-r" >> $@.var; \
		echo "" >> $@.var; \
	        ${ICONV} -f UTF-8 -t KOI8-R $@ > $@.ru.koi8-r; \
	        ;; \
	    zh-CN) \
	        echo "URI: $@.$$LANG.gb2312" >> $@.var; \
	        echo "Content-language: $$LANG" >> $@.var; \
	        echo "Content-type: text/html;charset=GB2312" >> $@.var; \
	        echo "" >> $@.var; \
	        ${ICONV} -f UTF-8 -t GB2312 $@ > $@.gb2312; \
		;; \
	    tw|zh-TW) \
	        echo "URI: $@.$$LANG.big5" >> $@.var; \
	        echo "Content-language: $$LANG" >> $@.var; \
	        echo "Content-type: text/html;charset=Big5" >> $@.var; \
	        echo "" >> $@.var; \
	        ${ICONV} -f UTF-8 -t BIG-5 $@ > $@.big5; \
		;; \
	    *) \
		;; \
	    esac; \
	    echo >> $@.var; \
	done; \
	rm -f ${BASEDIR}/base.htm; \
	echo "."

clean-www:
	@for F in ${HTML}; do \
		echo "rm -f $$F $$F.var"; \
		rm -f $$F $$F.var; \
		for LANG in ${LANGUAGES}; do \
			echo "rm -f $$F.$$LANG.* $$F.$$LANG"; \
			rm -f $$F.$$LANG.* $$F.$$LANG; \
		done; \
	done

install-www:
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
			if [ -e "${HTMLDIR}/xsl/$$XSL" \
			     -a "${OVERWRITE}" = "" ]; then \
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
			if [ -e "${HTMLDIR}/m4/$$M4IN" \
			     -a "${OVERWRITE}" = "" ]; then \
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
		if [ -e "${HTMLDIR}/$$SF" \
		     -a "${OVERWRITE}" = "" ]; then \
			echo "$$SF exists; preserving"; \
		else \
			echo "${INSTALL_DATA} $$SF ${HTMLDIR}"; \
			${INSTALL_DATA} $$SF ${HTMLDIR}; \
		fi; \
		for LANG in ${LANGUAGES}; do \
			if [ -e "${HTMLDIR}/$$F.$$LANG" \
			     -a "${OVERWRITE}" = "" ]; then \
				echo "$$F.$$LANG exists; preserving"; \
			else \
				echo "${INSTALL_DATA} $$F.$$LANG ${HTMLDIR}"; \
				${INSTALL_DATA} $$F.$$LANG ${HTMLDIR}; \
			fi; \
		done; \
	done

.PHONY: install deinstall clean cleandir regress depend
.PHONY: install-www clean-www

include ${TOP}/mk/csoft.common.mk
include ${TOP}/mk/csoft.subdir.mk
