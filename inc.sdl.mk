# $Csoft: inc.sdl.mk,v 1.2 2001/10/30 07:15:02 vedge Exp $

HOMEPAGE=	http://www.libsdl.org/

SDLCFLAGS!=	sdl-config --cflags
SDLLIBS!=	sdl-config --libs
SDLVER!=	sdl-config --version

CFLAGS+=	${SDLCFLAGS}
LIBS+=		${SDLLIBS}

.BEGIN: inc-sdl-begin

inc-sdl-begin:
	@if [ "${SDLVER}" == "" ]; then \
		echo "-"; \
		echo "* SDL is missing."; \
		echo "* Get it from ${HOMEPAGE}"; \
		echo "-"; \
		exit 1; \
	fi

