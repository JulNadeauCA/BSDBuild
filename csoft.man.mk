# $Csoft: csoft.man.mk,v 1.1 2001/10/09 04:50:31 vedge Exp $

TYPE=		man

CENTER?=	documentation
RELEASE?=	$(CSOFT_MK_VERSION)

NROFF?=		nroff -Tascii
TBL?=		tbl

PREFIX?=	/usr/local
INSTALL?=	install
MANMODE?=	644
POD2MAN?=	pod2man

MANS=		$(MAN1) $(MAN2) $(MAN3) $(MAN4) $(MAN5) $(MAN6) $(MAN7) \
		$(MAN8) $(MAN9)

.SUFFIXES:  .1 .2 .3 .4 .5 .6 .7 .8 .9 .pod

.pod.1 .pod.2 .pod.3 .pod.4 .pod.5 .pod.6 .pod.7 .pod.8 .pod.9:
	@echo "===> $<"
	$(POD2MAN) '--center=$(CENTER)' '--release=$(RELEASE)' $< > $@

all: $(MANS)
all: all-subdir

clean: clean-subdir
	@rm -f *~

depend: depend-subdir

install: install-subdir $(MANS)
	@if [ "$(MAN1)" != "" ]; then \
	    echo "installing $(MAN1) into $(PREFIX)"; \
	    $(INSTALL) $(INSTALL_COPY) $(INSTALL_STRIP) \
	    $(BINOWN) $(BINGRP) -m $(MANMODE) $(MAN7) $(PREFIX)/man/man1; \
	fi
	@if [ "$(MAN2)" != "" ]; then \
	    echo "installing $(MAN1) into $(PREFIX)"; \
	    $(INSTALL) $(INSTALL_COPY) $(INSTALL_STRIP) \
	    $(BINOWN) $(BINGRP) -m $(MANMODE) $(MAN7) $(PREFIX)/man/man2; \
	fi
	@if [ "$(MAN3)" != "" ]; then \
	    echo "installing $(MAN1) into $(PREFIX)"; \
	    $(INSTALL) $(INSTALL_COPY) $(INSTALL_STRIP) \
	    $(BINOWN) $(BINGRP) -m $(MANMODE) $(MAN7) $(PREFIX)/man/man3; \
	fi
	@if [ "$(MAN4)" != "" ]; then \
	    echo "installing $(MAN1) into $(PREFIX)"; \
	    $(INSTALL) $(INSTALL_COPY) $(INSTALL_STRIP) \
	    $(BINOWN) $(BINGRP) -m $(MANMODE) $(MAN7) $(PREFIX)/man/man4; \
	fi
	@if [ "$(MAN5)" != "" ]; then \
	    echo "installing $(MAN1) into $(PREFIX)"; \
	    $(INSTALL) $(INSTALL_COPY) $(INSTALL_STRIP) \
	    $(BINOWN) $(BINGRP) -m $(MANMODE) $(MAN7) $(PREFIX)/man/man5; \
	fi
	@if [ "$(MAN6)" != "" ]; then \
	    echo "installing $(MAN1) into $(PREFIX)"; \
	    $(INSTALL) $(INSTALL_COPY) $(INSTALL_STRIP) \
	    $(BINOWN) $(BINGRP) -m $(MANMODE) $(MAN7) $(PREFIX)/man/man6; \
	fi
	@if [ "$(MAN7)" != "" ]; then \
	    echo "installing $(MAN7) into $(PREFIX)"; \
	    $(INSTALL) $(INSTALL_COPY) $(INSTALL_STRIP) \
	    $(BINOWN) $(BINGRP) -m $(MANMODE) $(MAN7) $(PREFIX)/man/man7; \
	fi
	@if [ "$(MAN8)" != "" ]; then \
	    echo "installing $(MAN9) into $(PREFIX)"; \
	    $(INSTALL) $(INSTALL_COPY) $(INSTALL_STRIP) \
	    $(BINOWN) $(BINGRP) -m $(MANMODE) $(MAN9) $(PREFIX)/man/man8; \
	fi
	@if [ "$(MAN9)" != "" ]; then \
	    echo "installing $(MAN9) into $(PREFIX)"; \
	    $(INSTALL) $(INSTALL_COPY) $(INSTALL_STRIP) \
	    $(BINOWN) $(BINGRP) -m $(MANMODE) $(MAN9) $(PREFIX)/man/man9; \
	fi
	
uninstall: uninstall-subdir
	@if [ "$(MAN1)" != "" ]; then \
	    echo "deinstalling $(MAN1) from $(PREFIX)"; \
	    (cd $(PREFIX)/man/man1 && rm -f $(MAN1)); \
	fi
	@if [ "$(MAN2)" != "" ]; then \
	    echo "deinstalling $(MAN2) from $(PREFIX)"; \
	    (cd $(PREFIX)/man/man2 && rm -f $(MAN2)); \
	fi
	@if [ "$(MAN3)" != "" ]; then \
	    echo "deinstalling $(MAN3) from $(PREFIX)"; \
	    (cd $(PREFIX)/man/man3 && rm -f $(MAN3)); \
	fi
	@if [ "$(MAN4)" != "" ]; then \
	    echo "deinstalling $(MAN4) from $(PREFIX)"; \
	    (cd $(PREFIX)/man/man4 && rm -f $(MAN4)); \
	fi
	@if [ "$(MAN5)" != "" ]; then \
	    echo "deinstalling $(MAN5) from $(PREFIX)"; \
	    (cd $(PREFIX)/man/man5 && rm -f $(MAN5)); \
	fi
	@if [ "$(MAN6)" != "" ]; then \
	    echo "deinstalling $(MAN6) from $(PREFIX)"; \
	    (cd $(PREFIX)/man/man6 && rm -f $(MAN6)); \
	fi
	@if [ "$(MAN7)" != "" ]; then \
	    echo "deinstalling $(MAN7) from $(PREFIX)"; \
	    (cd $(PREFIX)/man/man7 && rm -f $(MAN7)); \
	fi
	@if [ "$(MAN8)" != "" ]; then \
	    echo "deinstalling $(MAN8) from $(PREFIX)"; \
	    (cd $(PREFIX)/man/man8 && rm -f $(MAN8)); \
	fi
	@if [ "$(MAN9)" != "" ]; then \
	    echo "deinstalling $(MAN9) from $(PREFIX)"; \
	    (cd $(PREFIX)/man/man9 && rm -f $(MAN9)); \
	fi

include $(TOP)/mk/csoft.common.mk
include $(TOP)/mk/csoft.subdir.mk
