# $Csoft: inc.glib.mk,v 1.1 2001/12/01 03:57:42 vedge Exp $

HOMEPAGE=	http://www.gtk.org/

GLIBCFLAGS!=	glib-config --cflags 2>/dev/null
GLIBLIBS!=	glib-config --libs 2>/dev/null
GLIBVER!=	glib-config --version 2>/dev/null

CFLAGS+=	${GLIBCFLAGS}
LIBS+=		${GLIBLIBS}

.BEGIN: inc-sdl-begin

inc-sdl-begin:
	@if [ "${GLIBVER}" == "" ]; then \
		echo "-"; \
		echo "* Glib is missing."; \
		echo "* Get it from ${HOMEPAGE}"; \
		echo "-"; \
		exit 1; \
	fi

