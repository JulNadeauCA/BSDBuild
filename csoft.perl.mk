# $Csoft: csoft.perl.mk,v 1.1 2001/10/09 04:50:31 vedge Exp $

TYPE=	    perl

PREFIX?=    /usr/local
SH?=	    sh
INSTALL?=   install -c
PERLMODE?=   755

.SUFFIXES:  .PL .pl .pm .perl

all: all-subdir

clean: clean-subdir
	@rm -f *~

depend: depend-subdir

install: install-subdir
	@if [ "$(OBJS)" != "" ]; then \
	    for OBJ in $(OBJS); do \
		echo "===> $$OBJ"; \
		$(INSTALL) $(BINOWN) $(BINGRP) -m $(PERLMODE) \
		    $$OBJ $(PREFIX); \
	    done; \
	fi
	
uninstall: uninstall-subdir
	@if [ "$(OBJS)" != "" ]; then \
	    for OBJ in $(OBJS); do \
		echo "===> $$OBJ"; \
		rm -f $(PREFIX)/$$OBJ; \
	    done; \
	fi

regress: regress-subdir

include $(TOP)/mk/csoft.common.mk
include $(TOP)/mk/csoft.subdir.mk
