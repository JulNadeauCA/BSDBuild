# $Csoft: inc.sdl.mk,v 1.2 2001/10/30 07:15:02 vedge Exp $

GLIBCFLAGS!=	glib-config --cflags 2>/dev/null
GLIBLIBS!=	glib-config --libs 2>/dev/null
GLIBVER!=	glib-config --version 2>/dev/null

CFLAGS+=	${GLIBCFLAGS}
LIBS+=		${GLIBLIBS}

.BEGIN: inc-sdl-begin

inc-sdl-begin:
	@if [ "${GLIBVER}" == "" ]; then \
		echo "Glib is missing. Get it from http://www.gnu.org/"; \
		exit 1; \
	fi

