# $Id$

TYPE=	    www

include %TOP%/config.mk

DOCROOT?=   ./docroot
M4?=	    m4
MAKE?=	    make
INSTALL?=   install
HTMLMODE?=  644

.SUFFIXES=  .htm .html .jpg .jpeg .png .gif .m4

.htm.html: base/html.m4
	@echo "===> $@"
	@cp -f $< base/base.htm
	@m4 base/html.m4 > $@

ALL: $(HTML) all-subdir

clean: clean-subdir
	rm -f $(HTML) a.out
distclean:
	rm -f `find %TOP% -name \.vedge\.\*\.mk`

install: install-subdir
	@if [ "$(HTML)" != "" ]; then \
	    $(INSTALL) $(INSTALL_COPY) $(INSTALL_STRIP) \
	    $(BINOWN) $(BINGRP) -m $(HTMLMODE) $(HTML) $(DOCROOT); \
	fi
	
uninstall: uninstall-subdir
	@if [ "$(HTML)" != "" ]; then \
	    @for DOC in $(HTML); do \
		rm -f $(DOCROOT)/$$DOC; \
	    done; \
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

