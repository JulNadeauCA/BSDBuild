# $Id$

TYPE=	    none

NONE?=	    dummy
PREFIX?=    /usr/local
SH?=	    sh
INSTALL?=   install
BINMODE?=   755

.SUFFIXES:  .nop .nos

.nos.nop:
	echo "$< -> $@"

ALL: $(NONE) all-subdir

$(NONE): $(OBJS)
	echo "($(OBJS)) -> $(NONE)"

clean: clean-subdir
	@rm -f $(NONE) $(OBJS)

depend: depend-subdir
	echo NOOP


install: install-subdir
	@if [ "$(NONE)" != "" ]; then \
	    $(INSTALL) $(INSTALL_COPY) $(INSTALL_STRIP) \
	    $(BINOWN) $(BINGRP) -m $(BINMODE) $(NONE) $(PREFIX)/bin; \
	fi
	
uninstall: uninstall-subdir
	@if [ "$(NONE)" != "" ]; then \
	    rm -f $(NONE) $(PREFIX)/bin; \
	fi

include $(TOP)/mk/vedge.common.mk
include $(TOP)/mk/vedge.subdir.mk
