TOP=	..
include ${TOP}/Makefile.config

PROG=		mlproc
PROG_TYPE=	"CLI"
PROG_GUID=	""

SRCS=		mlproc.c
CFLAGS+=	${GETTEXT_CFLAGS}
LIBS+=		${GETTEXT_LIBS}

all: ${PROG}

configure:
	cat configure.in | mkconfigure > configure
	chmod 755 configure

include ${TOP}/mk/build.prog.mk

.PHONY: configure
