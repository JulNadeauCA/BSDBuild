# $Id$

TYPE=	    lib

PREFIX?=    /usr/local
CFLAGS?=    -Wall -g
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
	rm -f $(LIB) $(OBJS) a.out

install: install-subdir
	@if [ "$(LIB)" != "" ]; then \
	    $(LIBTOOL) --mode=install \
	    $(INSTALL) $(INSTALL_COPY) $(INSTALL_STRIP) \
	    $(BINOWN) $(BINGRP) -m $(BINMODE) $(PROG) $(PREFIX)/lib; \
	fi
	
uninstall: uninstall-subdir
	@if [ "$(LIB)" != "" ]; then
	    rm -f $(LIB) $(PREFIX)/lib/$(LIB).*;
	fi

all-subdir:
	@for DIR in $(SUBDIR); do \
	    echo "===> $(REL)$$DIR"; \
	    (cd $$DIR && $(MAKE) REL=$(REL)$$DIR/); \
	done
clean-subdir:
	@for DIR in $(SUBDIR); do \
	    echo "===> $(REL)$$DIR"; \
	    (cd $$DIR && $(MAKE) REL=$(REL)$$DIR/ clean); \
	done
depend-subdir:
	@for DIR in $(SUBDIR); do \
	    echo "===> $(REL)$$DIR"; \
	    (cd $$DIR && $(MAKE) REL=$(REL)$$DIR/ depend); \
	done
install-subdir:
	@for DIR in $(SUBDIR); do \
	    echo "===> $(REL)$$DIR"; \
	    (cd $$DIR && $(MAKE) REL=$(REL)$$DIR/ install); \
	done
uninstall-subdir:
	@for DIR in $(SUBDIR); do \
	    echo "===> $(REL)$$DIR"; \
	    (cd $$DIR && $(MAKE) REL=$(REL)$$DIR/ uninstall); \
	done

