# $Csoft$

SDLCFLAGS!= sdl-config --cflags
SDLLIBS!=   sdl-config --libs

CFLAGS+=    ${SDLCFLAGS}
LIBS+=	    ${SDLLIBS}

