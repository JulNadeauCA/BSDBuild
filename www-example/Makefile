# $Csoft: Makefile,v 1.35 2002/08/10 04:48:55 vedge Exp $

TOP=.

HTML=		index.html

include ${TOP}/mk/csoft.www.mk

spam.db: .PHONY
	cp -f /var/csoftadm/relay.db spam.db
	chmod 644 spam.db
#	scp probe@urath2:relays.db .
#	cat ~csoftadm/relay.db >> relays.db
#	@if [ -e "spam.db" ]; then \
#		mv -f spam.db spam.db~; \
#	fi
#	mv -f relays.db spam.db
#	chmod 644 spam.db

