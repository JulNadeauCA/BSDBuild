# $Csoft: inc.sdl.mk,v 1.1 2001/08/16 05:52:57 vedge Exp $

SDLCFLAGS!=	sdl-config --cflags
SDLLIBS!=	sdl-config --libs
SDLVER!=	sdl-config --version

CFLAGS+=	${SDLCFLAGS}
LIBS+=		${SDLLIBS}

.BEGIN: inc-sdl-begin

inc-sdl-begin:
	@if [ "`sdl-config --version 2>/dev/null`" == "" ]; then \
		echo "SDL is missing. Get it from http://www.libsdl.org/"; \
		exit 1; \
	fi

