# $Csoft: csoft.lib.mk,v 1.4 2001/12/03 04:47:00 vedge Exp $

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
# DAMAGES {INCLUDING BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION} HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT {INCLUDING NEGLIGENCE OR OTHERWISE} ARISING IN ANY WAY OUT OF THE
# USE OF THIS SOFTWARE EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

PREFIX?=	/usr/local
CFLAGS?=	-Wall -g
SH?=		sh
CC?=		cc
AR?=		ar
RANLIB?=	ranlib
MAKE?=		make
INSTALL?=	install

# XXX elf
ASM?=		nasm
ASMOUT?=	aoutb
ASMFLAGS=	-f ${ASMOUT} -g -w-orphan-labels

LIBTOOL?=	libtool
LTCONFIG?=	./ltconfig
LTMAIN_SH?=	./ltmain.sh
LTCONFIG_GUESS?=./config.guess
LTCONFIG_SUB?=	./config.sub
LTCONFIG_LOG?=	./config.log

BINMODE?=	755

STATIC?=	Yes
SHARED?=	No
VERSION?=	1:0:0

.SUFFIXES:  .o .lo .c .cc .C .cxx .s .S .asm .y

CFLAGS+=    ${COPTS}

.c.o:
	${CC} ${CFLAGS} -c $<
.cc.o:
	${CXX} ${CXXFLAGS} -c $<
.c.lo:
	${LIBTOOL} ${CC} ${CFLAGS} -c $<
.cc.lo:
	${LIBTOOL} ${CXX} ${CXXFLAGS} -c $<
.asm.o:
	${ASM} ${ASMFLAGS} -o $@ $< 

all:	all-subdir lib${LIB}.a lib${LIB}.la

lib${LIB}.a:	${OBJS}
	@if [ "${STATIC}" = "Yes" ]; then \
	    echo "===> lib${LIB}.a"; \
	    ${AR} -cru lib${LIB}.a ${OBJS}; \
	    ${RANLIB} lib${LIB}.a; \
	fi

lib${LIB}.la:	${LIBTOOL} ${SHOBJS}
	@if [ "${SHARED}" = "Yes" ]; then \
	    echo "===> lib${LIB}.la"; \
	    ${LIBTOOL} ${CC} -o lib${LIB}.la -rpath ${PREFIX}/lib -shared \
		-version-info ${VERSION} ${LDFLAGS} ${SHOBJS} ${LIBS}; \
	fi

clean:		clean-subdir
	@rm -fr lib${LIB}.a lib${LIB}.la libs ${OBJS} ${SHOBJS}
	@rm -f ${LIBTOOL} ${LTCONFIG_LOG}

install:	install-subdir lib${LIB}.a lib${LIB}.la
	@if [ "${STATIC}" = "Yes" ]; then \
	    echo "===> installing lib${LIB}.a"; \
	    ${INSTALL} ${INSTALL_COPY} ${INSTALL_STRIP} \
		${BINOWN} ${BINGRP} -m ${BINMODE} lib${LIB}.a ${PREFIX}/lib; \
	fi
	@if [ "${SHARED}" = "Yes" ]; then \
	    echo "===> installing lib${LIB}.la"; \
	    ${LIBTOOL} --mode=install \
	    ${INSTALL} ${INSTALL_COPY} ${INSTALL_STRIP} \
		${BINOWN} ${BINGRP} -m ${BINMODE} lib${LIB}.la ${PREFIX}/lib; \
	fi
	
uninstall:	uninstall-subdir
	@if [ "${STATIC}" = "Yes" ]; then \
	    echo "===> uninstalling lib${LIB}.a"; \
		rm -f ${PREFIX}/lib/lib${LIB}.a; \
	fi
	@if [ "${SHARED}" = "Yes" ]; then \
	    echo "===> uninstalling lib${LIB}.la"; \
	    ${LIBTOOL} --mode=uninstall \
		rm -f ${PREFIX}/lib/lib${LIB}.la; \
	fi

${LIBTOOL}:	${LTCONFIG} ${LTMAIN_SH} ${LTCONFIG_GUESS} ${LTCONFIG_SUB}
	@if [ "${SHARED}" = "Yes" ]; then \
	    ${SH} ${LTCONFIG} ${LTMAIN_SH}; \
	fi

regress:	regress-subdir

include ${TOP}/mk/csoft.common.mk
include ${TOP}/mk/csoft.subdir.mk
