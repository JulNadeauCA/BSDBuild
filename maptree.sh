#!/bin/sh
#
# $Csoft: maptree.sh,v 1.6 2001/12/03 04:47:00 vedge Exp $
#
# Copyright (c) 2001 CubeSoft Communications, Inc. <http://www.csoft.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistribution of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Neither the name of CubeSoft Communications, nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
# USE OF THIS SOFTWARE EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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

