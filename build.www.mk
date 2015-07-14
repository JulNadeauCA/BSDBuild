#
# Copyright (c) 2001-2015 Hypertriton, Inc. <http://hypertriton.com/>
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

#
# Compile a set of HTML files (language and character set variants) from
# source files processed by m4 and xsltproc.
#

M4?=		m4
M4FLAGS?=
XSLTPROC?=	xsltproc
XSLTPROCFLAGS?=	--nonet
PERL?=		perl
ICONV?=		iconv
BASEDIR?=	${TOP}/m4
XSLDIR?=	${TOP}/xsl
TEMPLATE?=	simple
TEMPLATE_DEPS?=
LANGUAGES?=	en fr
CHARSETS?=	utf8 iso8859-1
DEF_LANGUAGE?=	en
XSL?=		${XSLDIR}/ml.xsl
MKDEPS=		build.www.mk build.subdir.mk build.common.mk hstrip.pl
CLEANFILES?=
HTMLDIR?=	none
HTML?=
HTML_EXTRA?=
CSS?=
CSS_TEMPLATE?=style
CSS_TEMPLATE_DEPS?=
HTML_OVERWRITE?=No
HTML_INSTSOURCE?=Yes
HTML_STRIP?=${PERL} ${TOP}/mk/hstrip.pl

DTD?=	<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"  \
	"http://www.w3.org/TR/html4/loose.dtd">

all: ${HTML} ${CSS} all-subdir
clean: clean-www clean-subdir
cleandir: clean-www clean-subdir cleandir-subdir
install: install-www install-subdir
deinstall: deinstall-subdir
regress: regress-subdir
depend: depend-subdir

.SUFFIXES: .html.var .html .htm .jpg .jpeg .png .gif .m4 .css .css-in

.css-in.css: ${BASEDIR}/${CSS_TEMPLATE}.m4 ${CSS_TEMPLATE_DEPS}
	@cp -f $< ${BASEDIR}/base.css
	@echo -n "$@:"
	${M4} ${M4FLAGS} -D__BASE_DIR=${BASEDIR} -D__FILE=$@ \
	    -D__LANG=$$LANG ${BASEDIR}/${CSS_TEMPLATE}.m4 | ${HTML_STRIP} > $@
	@rm -f ${BASEDIR}/base.css

.htm.html: ${BASEDIR}/${TEMPLATE}.m4 ${TEMPLATE_DEPS}
	@cp -f $< ${BASEDIR}/base.htm
	@echo "${M4} $< | ${XSLTPROC} > $@"
	@export OUT=".$@.tmp"; \
	${M4} ${M4FLAGS} -D__BASE_DIR=${BASEDIR} -D__FILE=$@ \
	    -D__TEMPLATE=${TEMPLATE} -D__LANG=${DEF_LANGUAGE} \
	        ${BASEDIR}/${TEMPLATE}.m4 | \
		${HTML_STRIP} > "$$OUT"; \
	echo '${DTD}' > $@; \
	${XSLTPROC} ${XSLTPROCFLAGS} --html --stringparam lang ${DEF_LANGUAGE} ${XSL} \
	    "$$OUT" 2>/dev/null | ${HTML_STRIP} >> $@ 2>/dev/null; \
	rm -f "$$OUT" ${BASEDIR}/base.htm

.htm.html.var: ${BASEDIR}/${TEMPLATE}.m4 ${TEMPLATE_DEPS}
	@for CHARSET in ${CHARSETS}; do \
	    if [ ! -e "$$CHARSET" ]; then mkdir $$CHARSET; fi; \
	done
	@cp -f $< ${BASEDIR}/base.htm
	@export BASE="`echo $@ | sed s/\.var//`"; \
	echo -n "$$BASE:"; \
	echo > $@; \
	for LANG in ${LANGUAGES}; do \
	    export OUT=".$BASE.$$LANG.tmp"; \
	    echo -n " $$LANG"; \
	    ${M4} ${M4FLAGS} -D__BASE_DIR=${BASEDIR} -D__FILE=$$BASE \
	        -D__TEMPLATE=${TEMPLATE} -D__LANG=$$LANG \
	        ${BASEDIR}/${TEMPLATE}.m4 | ${HTML_STRIP} > $$OUT; \
	    echo '${DTD}' > utf8/$$BASE.$$LANG; \
            ${XSLTPROC} --html ${XSLTPROCFLAGS} --stringparam lang $$LANG ${XSL} \
	        $$OUT 2>/dev/null | ${HTML_STRIP} >> utf8/$$BASE.$$LANG; \
	    cp -f utf8/$$BASE.$$LANG $$BASE.$$LANG; \
	    rm -f $$OUT; \
	    cat utf8/$$BASE.$$LANG | \
		sed s/charset=UTF-8/charset=ISO-8859-1/ | \
		${ICONV} -f UTF-8 -t ISO-8859-1 > iso8859-1/$$BASE.$$LANG; \
	    echo "Content-Type: text/html; charset=UTF-8" >> $@; \
	    echo "Content-Language: $$LANG" >> $@; \
	    echo "URI: utf8/$$BASE.$$LANG" >> $@; \
	    echo "" >> $@; \
	    echo "Content-Type: text/html; charset=ISO-8859-1" >> $@; \
	    echo "Content-Language: $$LANG" >> $@; \
	    echo "URI: iso8859-1/$$BASE.$$LANG" >> $@; \
	    echo "" >> $@; \
	done; \
	rm -f ${BASEDIR}/base.htm; \
	echo "."

clean-www:
	@echo -n "Clean:"
	@for F in ${HTML}; do \
		if [ "`echo $$F | sed s/\.var//`" != "$$F" ]; then \
			export BASE="`echo $$F | sed s/\.var//`"; \
			echo -n " $$BASE"; \
			for LANG in ${LANGUAGES}; do \
				for CHARSET in ${CHARSETS}; do \
					rm -f $$CHARSET/$$BASE.$$LANG; \
				done; \
			done; \
			rm -f $$F; \
		else \
			echo -n " $$F"; \
		fi; \
	done
	@if [ "${CLEANFILES}" != "" ]; then \
	    echo " ${CLEANFILES}"; \
	    rm -f ${CLEANFILES}; \
	fi
	@echo "."

install-www-makefile:
	@export OUT=.Makefile.out; \
	echo "# Generated by <build.www.mk> install on `date`" > $$OUT; \
	echo "TOP=." >> $$OUT; \
	echo "HTMLDIR=none" >> $$OUT; \
	echo "BASEDIR=m4" >> $$OUT; \
	echo "XSLDIR=xsl" >> $$OUT; \
	echo "HTML=${HTML}" >> $$OUT; \
	echo "CSS=${CSS}" >> $$OUT; \
	echo "XSL=${XSL}" >> $$OUT; \
	echo "XSLTPROC=${XSLTPROC}" >> $$OUT; \
	echo "XSLTPROCFLAGS=${XSLTPROCFLAGS}" >> $$OUT; \
	echo "M4=${M4}" >> $$OUT; \
	echo "PERL=${PERL}" >> $$OUT; \
	echo "ICONV=${ICONV}" >> $$OUT; \
	echo "TEMPLATE=${TEMPLATE}" >> $$OUT; \
	echo "CSS_TEMPLATE=${CSS_TEMPLATE}" >> $$OUT; \
	echo "LANGUAGES=${LANGUAGES}" >> $$OUT; \
	echo "CHARSETS=${CHARSETS}" >> $$OUT; \
	echo "DEF_LANGUAGE=${DEF_LANGUAGE}" >> $$OUT; \
	echo "include mk/build.www.mk" >> $$OUT; \
	echo "${INSTALL_DATA} $$OUT ${HTMLDIR}/Makefile"; \
	${SUDO} ${INSTALL_DATA} $$OUT ${DESTDIR}${HTMLDIR}/Makefile; \
	rm -f $$OUT

install-www-source:
	@if [ -e "${DESTDIR}${HTMLDIR}/$$SRCFILE" \
	      -a "${HTML_OVERWRITE}" = "" ]; then \
		echo "${HTMLDIR}/$$SRCFILE exists; preserving"; \
	else \
		echo "${INSTALL_DATA} $$SRCFILE ${HTMLDIR}"; \
		${SUDO} ${INSTALL_DATA} $$SRCFILE ${DESTDIR}${HTMLDIR}; \
	fi
	@if [ -e "${DESTDIR}${HTMLDIR}/Makefile"  \
	      -a "${HTML_OVERWRITE}" = "" ]; then \
		echo "${HTMLDIR}/Makefile exists; preserving"; \
	else
		${MAKE} install-www-makefile; \
	fi

install-www-base:
	@if [ ! -d "${DESTDIR}${HTMLDIR}/mk" ]; then \
		echo "${INSTALL_DATA_DIR} ${HTMLDIR}/mk"; \
		${SUDO} ${INSTALL_DATA_DIR} ${DESTDIR}${HTMLDIR}/mk; \
	fi
	@for MK in ${MKDEPS}; do \
		echo "${INSTALL_DATA} ${TOP}/mk/$$MK ${HTMLDIR}/mk"; \
		${SUDO} ${INSTALL_DATA} ${TOP}/mk/$$MK ${DESTDIR}${HTMLDIR}/mk; \
	done
	@if [ ! -d "${DESTDIR}${HTMLDIR}/xsl" ]; then \
		echo "${INSTALL_DATA_DIR} ${HTMLDIR}/xsl"; \
		${SUDO} ${INSTALL_DATA_DIR} ${DESTDIR}${HTMLDIR}/xsl; \
	fi
	@for XSL in ${XSL}; do \
		if [ -e "${DESTDIR}${HTMLDIR}/xsl/$$XSL" \
		     -a "${HTML_OVERWRITE}" = "" ]; then \
			echo "xsl/$$XSL: exists; preserving"; \
		else \
			echo "${INSTALL_DATA} $$XSL ${HTMLDIR}/xsl"; \
			${SUDO} ${INSTALL_DATA} $$XSL ${DESTDIR}${HTMLDIR}/xsl; \
		fi; \
	done
	@if [ ! -d "${DESTDIR}${HTMLDIR}/m4" ]; then \
		echo "${INSTALL_DATA_DIR} ${HTMLDIR}/m4"; \
		${SUDO} ${INSTALL_DATA_DIR} ${DESTDIR}${HTMLDIR}/m4; \
	fi
	@(cd ${BASEDIR}; for M4IN in `ls -1 *.m4`; do \
		if [ -e "${DESTDIR}${HTMLDIR}/m4/$$M4IN" \
		     -a "${HTML_OVERWRITE}" = "" ]; then \
			echo "m4/$$M4IN: exists; preserving"; \
		else \
			echo "${INSTALL_DATA} $$M4IN ${HTMLDIR}/m4"; \
			${SUDO} ${INSTALL_DATA} $$M4IN ${DESTDIR}${HTMLDIR}/m4; \
		fi; \
	done)

install-www:
	@if [ "${HTMLDIR}" = "none" ]; then \
		exit 0; \
	fi
	@for CHARSET in ${CHARSETS}; do \
		echo "${INSTALL_DATA_DIR} ${HTMLDIR}/$$CHARSET"; \
		${SUDO} ${INSTALL_DATA_DIR} ${DESTDIR}${HTMLDIR}/$$CHARSET; \
	done
	@if [ ! -d "${DESTDIR}${HTMLDIR}" ]; then \
		echo "${INSTALL_DATA_DIR} ${HTMLDIR}"; \
		${SUDO} ${INSTALL_DATA_DIR} ${DESTDIR}${HTMLDIR}; \
	fi
	@if [ "${HTML_INSTSOURCE}" = "Yes" ]; then \
		${MAKE} install-www-base; \
	fi
	@for F in ${HTML_EXTRA}; do \
	    echo "${INSTALL_DATA} $$F ${HTMLDIR}"; \
	    ${SUDO} ${INSTALL_DATA} $$F ${DESTDIR}${HTMLDIR}; \
	done
	@for F in ${HTML}; do \
		export BASE="`echo $$F | sed s/\.var//`"; \
		if [ "${HTML_INSTSOURCE}" = "Yes" ]; then \
			${MAKE} install-www-source \
			    SRCFILE="`echo $$BASE |sed s,.html$$,.htm,`"; \
		fi; \
		if [ -e "${DESTDIR}${HTMLDIR}/$$F" \
		     -a "${HTML_OVERWRITE}" = "" ]; then \
			echo "$$F exists; preserving"; \
		else \
			echo "${INSTALL_DATA} $$F ${HTMLDIR}"; \
			${SUDO} ${INSTALL_DATA} $$F ${DESTDIR}${HTMLDIR}; \
		fi; \
		for LANG in ${LANGUAGES}; do \
			if [ -e "${DESTDIR}${HTMLDIR}/$$BASE.$$LANG" \
			     -a "${HTML_OVERWRITE}" = "" ]; then \
				echo "$$BASE.$$LANG exists; preserving"; \
			else \
				echo "${INSTALL_DATA} $$BASE.$$LANG ${HTMLDIR}"; \
				${SUDO} ${INSTALL_DATA} $$BASE.$$LANG ${DESTDIR}${HTMLDIR}; \
			fi; \
			for CHARSET in ${CHARSETS}; do \
				if [ -e "$$CHARSET/$$BASE.$$LANG" ]; then \
					if [ -e "${DESTDIR}${HTMLDIR}/$$CHARSET/$$BASE.$$LANG" \
					     -a "${HTML_OVERWRITE}" = "" ]; then \
						echo "$$CHARSET/$$BASE.$$LANG exists; preserving"; \
					else \
						echo "${INSTALL_DATA} $$CHARSET/$$BASE.$$LANG ${HTMLDIR}/$$CHARSET"; \
						${SUDO} ${INSTALL_DATA} $$CHARSET/$$BASE.$$LANG ${DESTDIR}${HTMLDIR}/$$CHARSET; \
					fi; \
				fi; \
			done; \
		done; \
	done

.PHONY: install deinstall clean cleandir regress depend clean-www
.PHONY: install-www install-www-makefile install-www-source install-www-base

include ${TOP}/mk/build.common.mk
include ${TOP}/mk/build.subdir.mk
