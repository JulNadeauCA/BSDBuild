# $Id$

TYPE=	    www

DOCROOT?=   ./docroot
M4?=	    m4
MAKE?=	    make
INSTALL?=   install
HTMLMODE?=  644
BASEDIR?=   %TOP%/base
TEMPLATE?=  fancy sober
DEFTMPL=    sober

.SUFFIXES:  .html .htm .jpg .jpeg .png .gif .m4

.htm.html:
	@for TMPL in $(TEMPLATE); do \
	    echo "===> $$TMPL-$@"; \
	    cp -f $< $(BASEDIR)/base.htm; \
	    $(M4) -D_TMPL_=$$TMPL -D_TOP_=%TOP% -D_BASE_=$(BASEDIR) \
		$(BASEDIR)/$$TMPL.m4 > $$TMPL-$@; \
	done
	@cp -f $(DEFTMPL)-$@ $@

ALL: $(HTML) all-subdir

clean: clean-subdir
	rm -f $(HTML) *.html
distclean:
	rm -f `find %TOP% -name \.vedge\.\*\.mk`
tree:
	sh %TOP%/mk/maptree.sh $(TYPE)

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

