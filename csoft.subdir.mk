# $Csoft: vedge.subdir.mk,v 1.2 2001/08/16 05:52:32 vedge Exp $

MAKE?=	    make

all-subdir:
	@for DIR in $(SUBDIR); do \
	    echo "==> $(REL)$$DIR"; \
	    (cd $$DIR && $(MAKE) REL=$(REL)$$DIR/); \
	done
clean-subdir:
	@for DIR in $(SUBDIR); do \
	    echo "==> $(REL)$$DIR"; \
	    (cd $$DIR && $(MAKE) REL=$(REL)$$DIR/ clean); \
	done
depend-subdir:
	@for DIR in $(SUBDIR); do \
	    echo "==> $(REL)$$DIR"; \
	    (cd $$DIR && $(MAKE) REL=$(REL)$$DIR/ depend); \
	done
install-subdir:
	@for DIR in $(SUBDIR); do \
	    echo "==> $(REL)$$DIR"; \
	    (cd $$DIR && $(MAKE) REL=$(REL)$$DIR/ install); \
	done
uninstall-subdir:
	@for DIR in $(SUBDIR); do \
	    echo "==> $(REL)$$DIR"; \
	    (cd $$DIR && $(MAKE) REL=$(REL)$$DIR/ uninstall); \
	done

