# $Id$

TYPE=	    prog

include %TOP%/config.mk

PREFIX?=    /usr/local
CFLAGS?=    -Wall -g
CC?=	    cc
AR?=	    ar
MAKE?=	    make
INSTALL?=   install
BINMODE?=   755

.SUFFIXES=  .o .c .cc .C .cxx .y .s .8 .7 .6 .5 .4 .3 .2 .1 .0

CFLAGS+=    $(COPTS)

.c.o:
	$(CC) $(CFLAGS) -c $<
.cc.o:
	$(CXX) $(CXXFLAGS) -c $<

ALL: $(PROG) $(MAN) all-subdir

$(PROG): $(OBJS)
	$(CC) $(LDFLAGS) $(LIBS) $(OBJS)

clean: clean-subdir
	rm -f $(PROG) $(OBJS) a.out
distclean:
	rm -f `find %TOP% -name \.vedge\.\*\.mk`

install: install-subdir
	@if [ "$(PROG)" != "" ]; then \
	    $(INSTALL) $(INSTALL_COPY) $(INSTALL_STRIP) \
	    $(BINOWN) $(BINGRP) -m $(BINMODE) $(PROG) $(PREFIX)/bin; \
	fi
	
uninstall: uninstall-subdir
	@if [ "$(PROG)" != "" ]; then rm -f $(PROG) $(PREFIX)/bin; fi

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

include %TOP%/mk/vedge.man.mk

