# $Csoft: vedge.www.mk,v 1.23 2001/09/15 02:58:37 vedge Exp $

TYPE=		www

DOCROOT?=	./docroot
M4?=		m4
M4FLAGS?=
INSTALL?=	install
HTMLMODE?=	644

BASEDIR?=	$(TOP)/base
TEMPLATE?=	fancy sober
DEFTMPL?=	sober


.SUFFIXES: .html .htm .jpg .jpeg .png .gif .m4

.htm.html:
	@for TMPL in $(TEMPLATE); do				\
	    echo "===> $$TMPL-$@";				\
	    cp -f $< $(BASEDIR)/base.htm;			\
	    $(M4) $(M4FLAGS) -D_TMPL_=$$TMPL			\
		-D_TOP_=$(TOP) -D_BASE_=$(BASEDIR) -D_FILE_=$@	\
		$(BASEDIR)/$$TMPL.m4 > $$TMPL-$@;		\
	done
	@cp -f $(DEFTMPL)-$@ $@

all: $(HTML) all-subdir

clean: clean-subdir
	@rm -f $(HTML) *.html

depend: depend-subdir

install: install-subdir $(HTML)
	@if [ "$(HTML)" != "" ]; then					\
	    $(INSTALL) $(INSTALL_COPY) $(INSTALL_STRIP)			\
	    $(BINOWN) $(BINGRP) -m $(HTMLMODE) $(HTML) $(DOCROOT);	\
	fi
	
uninstall: uninstall-subdir
	@if [ "$(HTML)" != "" ]; then	\
	    @for DOC in $(HTML); do	\
		rm -f $(DOCROOT)/$$DOC;	\
	    done;			\
	fi

include $(TOP)/mk/vedge.common.mk
include $(TOP)/mk/vedge.subdir.mk
