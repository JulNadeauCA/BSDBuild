# $Csoft: csoft.lib.mk,v 1.2 2001/10/30 07:10:15 vedge Exp $

TYPE=		lib

PREFIX?=	/usr/local
CFLAGS?=	-Wall -g
SH?=		sh
CC?=		cc
AR?=		ar
RANLIB?=	ranlib
MAKE?=		make
INSTALL?=	install
ASM?=		nasm
ASMOUT?=	aoutb
ASMFLAGS=	-f $(ASMOUT) -g -w-orphan-labels

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

.SUFFIXES:  .o .c .cc .C .cxx .y .s .S .asm .lo

CFLAGS+=    $(COPTS)

.c.o:
	$(CC) $(CFLAGS) -c $<
.cc.o:
	$(CXX) $(CXXFLAGS) -c $<
.c.lo:
	$(LIBTOOL) $(CC) $(CFLAGS) -c $<
.cc.lo:
	$(LIBTOOL) $(CXX) $(CXXFLAGS) -c $<
.asm.o:
	$(ASM) $(ASMFLAGS) -o $@ $< 

all: all-subdir lib$(LIB).a lib$(LIB).la

lib$(LIB).a: $(OBJS)
	@if [ "$(STATIC)" = "Yes" ]; then \
	    echo "===> lib$(LIB).a"; \
	    $(AR) -cru lib$(LIB).a $(OBJS); \
	    $(RANLIB) lib$(LIB).a; \
	fi

lib$(LIB).la: $(LIBTOOL) $(SHOBJS)
	@if [ "$(SHARED)" = "Yes" ]; then \
	    echo "===> lib$(LIB).la"; \
	    $(LIBTOOL) $(CC) -o lib$(LIB).la -rpath $(PREFIX)/lib -shared \
		-version-info $(VERSION) $(LDFLAGS) $(SHOBJS) $(LIBS); \
	fi

clean: clean-subdir
	@rm -fr lib$(LIB).a lib$(LIB).la libs $(OBJS) $(SHOBJS)
	@rm -f $(LIBTOOL) $(LTCONFIG_LOG)

install: install-subdir lib$(LIB).a lib$(LIB).la
	@if [ "$(STATIC)" = "Yes" ]; then \
	    echo "===> installing lib$(LIB).a"; \
	    $(INSTALL) $(INSTALL_COPY) $(INSTALL_STRIP) \
		$(BINOWN) $(BINGRP) -m $(BINMODE) lib$(LIB).a $(PREFIX)/lib; \
	fi
	@if [ "$(SHARED)" = "Yes" ]; then \
	    echo "===> installing lib$(LIB).la"; \
	    $(LIBTOOL) --mode=install \
	    $(INSTALL) $(INSTALL_COPY) $(INSTALL_STRIP) \
		$(BINOWN) $(BINGRP) -m $(BINMODE) lib$(LIB).la $(PREFIX)/lib; \
	fi
	
uninstall: uninstall-subdir
	@if [ "$(STATIC)" = "Yes" ]; then \
	    echo "===> uninstalling lib$(LIB).a"; \
		rm -f $(PREFIX)/lib/lib$(LIB).a; \
	fi
	@if [ "$(SHARED)" = "Yes" ]; then \
	    echo "===> uninstalling lib$(LIB).la"; \
	    $(LIBTOOL) --mode=uninstall \
		rm -f $(PREFIX)/lib/lib$(LIB).la; \
	fi

$(LIBTOOL): $(LTCONFIG) $(LTMAIN_SH) $(LTCONFIG_GUESS) $(LTCONFIG_SUB)
	@if [ "$(SHARED)" = "Yes" ]; then \
	    $(SH) $(LTCONFIG) $(LTMAIN_SH); \
	fi

regress: regress-subdir

include $(TOP)/mk/csoft.common.mk
include $(TOP)/mk/csoft.subdir.mk
