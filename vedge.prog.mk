# $Id$

TYPE=	    prog

PREFIX?=    /usr/local
CFLAGS?=    -Wall -g
SH?=	    sh
CC?=	    cc
MAKE?=	    make
INSTALL?=   install
BINMODE?=   755

.SUFFIXES:  .o .c .cc .C .cxx .y .s .8 .7 .6 .5 .4 .3 .2 .1 .0

CFLAGS+=    $(COPTS)

.c.o:
	$(CC) $(CFLAGS) -c $<
.cc.o:
	$(CXX) $(CXXFLAGS) -c $<

ALL: $(PROG) $(MAN) all-subdir

$(PROG): $(OBJS)
	$(CC) $(LDFLAGS) -o $(PROG) $(OBJS) $(LIBS)

clean: clean-subdir
	rm -f $(PROG) $(OBJS)

install: install-subdir
	@if [ "$(PROG)" != "" ]; then \
	    $(INSTALL) $(INSTALL_COPY) $(INSTALL_STRIP) \
	    $(BINOWN) $(BINGRP) -m $(BINMODE) $(PROG) $(PREFIX)/bin; \
	fi
	
uninstall: uninstall-subdir
	@if [ "$(PROG)" != "" ]; then \
	    rm -f $(PROG) $(PREFIX)/bin; \
	fi

tree:
	(cd $(TOP)/mk && $(SH) maptree.sh none)

include $(TOP)/mk/vedge.common.mk
include $(TOP)/mk/vedge.subdir.mk
