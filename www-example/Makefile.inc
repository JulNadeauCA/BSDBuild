# vim:syn=make

TEMPLATES=	fanatic
DEFAULT_TMPL=	fanatic

HOSTNAME!=	hostname
.if ${HOSTNAME} == "lucky"
M4FLAGS=	-DBASEURL="http://lucky.cn/vedge-www"
.else
M4FLAGS=	-DBASEURL="http://vedge.com.ar"
.endif

