# $Csoft: vedge.man.mk,v 1.6 2001/08/16 05:52:32 vedge Exp $

TYPE=	    man

CENTER?=    documentation
RELEASE?=   $(CSOFT_MK_VERSION)

NROFF?=	    nroff -Tascii
TBL?=	    tbl

PREFIX?=    /usr/local
INSTALL?=   install
MANMODE?=   644
POD2MAN?=   pod2man

.SUFFIXES:  .1 .2 .3 .4 .5 .6 .7 .8 .9 .pod

.pod.7:
	@echo "===> $<"
	$(POD2MAN) '--center=$(CENTER)' '--release=$(RELEASE)' $< > $@
.pod.9:
	@echo "===> $<"
	$(POD2MAN) '--center=$(CENTER)' '--release=$(RELEASE)' $< > $@

all: $(MAN7) $(MAN9) all-subdir

clean: clean-subdir
	@rm -f $(MAN7) $(MAN9)

depend: depend-subdir

install: install-subdir $(MAN7) $(MAN9)
	@if [ "$(MAN7)" != "" ]; then \
	    echo "installing $(MAN7) into $(PREFIX)"; \
	    $(INSTALL) $(INSTALL_COPY) $(INSTALL_STRIP) \
	    $(BINOWN) $(BINGRP) -m $(MANMODE) $(MAN7) $(PREFIX)/man/man7; \
	fi
	@if [ "$(MAN9)" != "" ]; then \
	    echo "installing $(MAN9) into $(PREFIX)"; \
	    $(INSTALL) $(INSTALL_COPY) $(INSTALL_STRIP) \
	    $(BINOWN) $(BINGRP) -m $(MANMODE) $(MAN9) $(PREFIX)/man/man9; \
	fi
	
uninstall: uninstall-subdir
	# TODO

include $(TOP)/mk/csoft.common.mk
include $(TOP)/mk/csoft.subdir.mk
