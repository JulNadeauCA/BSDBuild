# $Csoft: csoft.prog.mk,v 1.1 2001/10/09 04:50:31 vedge Exp $

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
	    $(INSTALL) $(INSTALL_COPY) $(INSTALL_STRIP) \
	    $(BINOWN) $(BINGRP) -m $(BINMODE) $(PROG) $(PREFIX)/bin; \
	fi
	
uninstall: uninstall-subdir
	@if [ "$(PROG)" != "" ]; then \
	    rm -f $(PROG) $(PREFIX)/bin; \
	fi

regress: regress-subdir

include $(TOP)/mk/csoft.common.mk
include $(TOP)/mk/csoft.subdir.mk
