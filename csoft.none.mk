# $Csoft: csoft.none.mk,v 1.1 2001/10/09 04:50:31 vedge Exp $

TYPE=	    none

NONE?=	    dummy
PREFIX?=    /usr/local
SH?=	    sh
INSTALL?=   install
BINMODE?=   755

.SUFFIXES:  .nop .nos

.nos.nop:
	echo "$< -> $@"

all: $(NONE) all-subdir

$(NONE): $(OBJS)
	echo "($(OBJS)) -> $(NONE)"

clean: clean-subdir
	@rm -f $(NONE) $(OBJS)

depend: depend-subdir
	echo NOOP


install: install-subdir $(NONE)
	@if [ "$(NONE)" != "" ]; then \
	    $(INSTALL) $(INSTALL_COPY) $(INSTALL_STRIP) \
	    $(BINOWN) $(BINGRP) -m $(BINMODE) $(NONE) $(PREFIX)/bin; \
	fi
	
uninstall: uninstall-subdir
	@if [ "$(NONE)" != "" ]; then \
	    rm -f $(NONE) $(PREFIX)/bin; \
	fi

regress: regress-subdir

include $(TOP)/mk/csoft.common.mk
include $(TOP)/mk/csoft.subdir.mk
