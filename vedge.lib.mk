# $Id$

TYPE=	    lib

PREFIX?=    /usr/local
CFLAGS?=    -Wall -g
SH?=	    sh
CC?=	    cc
AR?=	    ar
RANLIB?=    ranlib
MAKE?=	    make
INSTALL?=   install
LIBTOOL?=   libtool
BINMODE?=   755
STATIC?=    Yes
SHARED?=    No

ASM?=	    nasm
ASMOUT?=    aoutb
ASMFLAGS?=  -f $(ASMOUT) -g -w-orphan-labels

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


all: all-subdir $(LIB)

$(LIB): $(OBJS)
	@if [ "$(STATIC)" = "Yes" ]; then \
	    echo "===> $(LIB)"; \
	    $(AR) -cru $(LIB) $(OBJS); \
	    $(RANLIB) $(LIB); \
	fi
	@if [ "$(SHARED)" = "Yes" ]; then \
	    echo "===> $(SHLIB)"; \
	    $(LIBTOOL) $(CC) -o $(SHLIB) -rpath $(PREFIX)/lib -shared \
		$(LDFLAGS) $(OBJS) $(LIBS); \
	fi

clean: clean-subdir
	@rm -f $(LIB) $(SHLIB) $(OBJS)

install: install-subdir $(LIB)
	@if [ "$(STATIC)" = "Yes" ]; then \
	    echo "===> installing $(LIB)"; \
	    $(INSTALL) $(INSTALL_COPY) $(INSTALL_STRIP) \
	    $(BINOWN) $(BINGRP) -m $(BINMODE) $(LIB) $(PREFIX)/lib; \
	fi
	@if [ "$(SHARED)" = "Yes" ]; then \
	    echo "===> installing $(SHLIB)"; \
	    $(LIBTOOL) --mode=install \
	    $(INSTALL) $(INSTALL_COPY) $(INSTALL_STRIP) \
	    $(BINOWN) $(BINGRP) -m $(BINMODE) $(SHLIB) $(PREFIX)/lib; \
	fi
	
uninstall: uninstall-subdir
	@if [ "$(STATIC)" = "Yes" ]; then \
	    echo "===> uninstalling $(LIB)"; \
	    rm -f $(PREFIX)/lib/$(LIB); \
	fi
	@if [ "$(SHARED)" = "Yes" ]; then \
	    echo "===> uninstalling $(SHLIB)"; \
	    $(LIBTOOL) --mode=uninstall \
	    rm -f $(PREFIX)/lib/$(SHLIB); \
	fi

include $(TOP)/mk/vedge.common.mk
include $(TOP)/mk/vedge.subdir.mk
