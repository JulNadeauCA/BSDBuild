#!/bin/sh
# $Id$

mklib=vedge
type=$1

if [ "$type" = "" ];
then
    echo "Usage: $0 [default-type]"
    exit
fi

for D in `find . -type d`;
do
    if [ ! -e "$D/Repository" ];
    then
	echo "==> $D"
	fun=`echo $D |perl -e 'while(<STDIN>) {$_=~s/\b\w+\b/\.\./g; print;}'`

	if [ ! -e "$D/Makefile" ];
	then
	    cat > $D/Makefile << EOF
# \$Id\$

TOP=%TOP%



include \$(TOP)/mk/$mklib.$type.mk
EOF
	fi
	echo "===> $D/Makefile"
	sed -e "s|%TOP%|$fun|" -e "s|%MK%|$fun/mk|" \
	    $D/Makefile > $D/.Makefile
	mv -f $D/.Makefile $D/Makefile
    fi
done

