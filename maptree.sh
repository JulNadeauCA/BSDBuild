#!/bin/sh
# $Id$

type=$1
if [ "$type" = "" ]; then
    echo "Usage: $0 [type]"
    exit
fi

here=`pwd`
me=vedge.$type.mk

for D in `find . -type d`; do
    echo "===> $D"
    fun=`echo $D |perl -e 'while(<STDIN>) { $_ =~ s/\b\w+\b/\.\./g; print; }'`
    sed -e "s|%TOP%|$fun|" mk/$me > $D/.$me
    if [ ! -e "$D/Makefile" ]; then
	cat > $D/Makefile << EOF
# \$Id\$

include .vedge.$type.mk
EOF
    fi
done

