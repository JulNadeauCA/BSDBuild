# $Csoft: csoft.prog.mk,v 1.3 2001/12/01 02:58:09 vedge Exp $

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

TYPE=		prog

PREFIX?=	/usr/local
CFLAGS?=	-Wall -g
INSTALL?=	install
BINMODE?=	755

CC?=		cc
CFLAGS?=	-O2
CPPFLAGS?=
CC_PICFLAGS?=	-fPIC -DPIC

AS?=		as
AS_PICFLAGS?=	-k

ASM?=		nasm
ASMOUT?=	aoutb
ASMFLAGS?=	-f $(ASMOUT) -g -w-orphan-labels
ASM_PICFLAGS?=	-DPIC

.SUFFIXES:  .o .c .cc .C .cxx .y .s .S .asm .so

.c.o:
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $<
.cc.o:
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -c $<
.s.o .S.o:
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $<
.c.so:
	$(CC) $(CC_PICFLAGS) $(CFLAGS) $(CPPFLAGS) -c $<
.cc.so:
	$(CXX) $(CC_PICFLAGS) $(CXXFLAGS) $(CPPFLAGS) -c $<
.s.so .S.so:
	$(CC) $(CC_PICFLAGS) $(CFLAGS) $(CPPFLAGS) -c $<
.asm.so:
	$(ASM) $(ASM_PICFLAGS) $(ASMFLAGS) $(CPPFLAGS) -o $@ $< 

all: $(PROG) all-subdir

$(PROG): $(OBJS)
	$(CC) $(LDFLAGS) -o $(PROG) $(OBJS) $(LIBS)

clean: clean-subdir
	@rm -f $(PROG) $(OBJS)

install: install-subdir $(PROG)
	@if [ "$(PROG)" != "" ]; then \
	    echo "$(INSTALL) $(INSTALL_COPY) $(INSTALL_STRIP) \
	    $(BINOWN) $(BINGRP) -m $(BINMODE) $(PROG) $(PREFIX)/bin"; \
	    $(INSTALL) $(INSTALL_COPY) $(INSTALL_STRIP) \
	    $(BINOWN) $(BINGRP) -m $(BINMODE) $(PROG) $(PREFIX)/bin; \
	fi
	
uninstall: uninstall-subdir
	@if [ "$(PROG)" != "" ]; then \
	    echo "rm -f $(PROG) $(PREFIX)/bin"; \
	    rm -f $(PROG) $(PREFIX)/bin; \
	fi

regress: regress-subdir

include $(TOP)/mk/csoft.common.mk
include $(TOP)/mk/csoft.subdir.mk
