# $Id$

TYPE=	    lib

PREFIX?=    /usr/local
CFLAGS?=    -Wall -g
SH?=	    sh
CC?=	    cc
AR?=	    ar
MAKE?=	    make
INSTALL?=   install
LIBTOOL?=   libtool
BINMODE?=   755

.SUFFIXES:  .c .cc .lo .la .al .so

CFLAGS+=    $(COPTS)

.c.lo:
	$(LIBTOOL) $(CC) $(CFLAGS) -c $<
.cc.lo:
	$(LIBTOOL) $(CXX) $(CXXFLAGS) -c $<

ALL: $(LIB) $(MAN) all-subdir

$(LIB): $(OBJS)
	$(CC) $(LDFLAGS) $(LIBS) $(OBJS)

clean: clean-subdir
	@rm -f $(LIB) $(OBJS) a.out

tree:
	(cd $(TOP)/mk && $(SH) maptree.sh none)

install: install-subdir $(LIB)
	@if [ "$(LIB)" != "" ]; then \
	    $(LIBTOOL) --mode=install \
	    $(INSTALL) $(INSTALL_COPY) $(INSTALL_STRIP) \
	    $(BINOWN) $(BINGRP) -m $(BINMODE) $(PROG) $(PREFIX)/lib; \
	fi
	
uninstall: uninstall-subdir
	@if [ "$(LIB)" != "" ]; then
	    rm -f $(LIB) $(PREFIX)/lib/$(LIB).*;
	fi

include $(TOP)/mk/vedge.common.mk
include $(TOP)/mk/vedge.subdir.mk
