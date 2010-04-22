# $Csoft: sdl.pm,v 1.17 2004/03/10 16:33:36 vedge Exp $
# vim:ts=4
#
# Copyright (c) 2002, 2003, 2004 CubeSoft Communications, Inc.
# <http://www.csoft.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
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

sub Test
{
	my ($ver) = @_;

	print << 'EOF';
DB4_CFLAGS=""
DB4_LIBS=""
DB4_VERSION=""
for path in /usr /usr/local /opt; do
	if [ -e "${path}/include/db4.7" ]; then
		DB4_CFLAGS="-I${path}/include/db4.7"
		DB4_VERSION="4.7"
	elif [ -e "${path}/include/db4.6" ]; then
		DB4_CFLAGS="-I${path}/include/db4.6"
		DB4_VERSION="4.6"
	elif [ -e "${path}/include/db4.5" ]; then
		DB4_CFLAGS="-I${path}/include/db4.5"
		DB4_VERSION="4.5"
	elif [ -e "${path}/include/db4.4" ]; then
		DB4_CFLAGS="-I${path}/include/db4.4"
		DB4_VERSION="4.4"
	elif [ -e "${path}/include/db4.3" ]; then
		DB4_CFLAGS="-I${path}/include/db4.3"
		DB4_VERSION="4.3"
	elif [ -e "${path}/include/db4.2" ]; then
		DB4_CFLAGS="-I${path}/include/db4.2"
		DB4_VERSION="4.2"
	elif [ -e "${path}/include/db47" ]; then
		DB4_CFLAGS="-I${path}/include/db47"
		DB4_VERSION="4.7"
	elif [ -e "${path}/include/db46" ]; then
		DB4_CFLAGS="-I${path}/include/db46"
		DB4_VERSION="4.6"
	elif [ -e "${path}/include/db45" ]; then
		DB4_CFLAGS="-I${path}/include/db45"
		DB4_VERSION="4.5"
	elif [ -e "${path}/include/db44" ]; then
		DB4_CFLAGS="-I${path}/include/db44"
		DB4_VERSION="4.4"
	elif [ -e "${path}/include/db43" ]; then
		DB4_CFLAGS="-I${path}/include/db43"
		DB4_VERSION="4.3"
	elif [ -e "${path}/include/db42" ]; then
		DB4_CFLAGS="-I${path}/include/db42"
		DB4_VERSION="4.2"
	elif [ -e "${path}/include/db4" ]; then
		DB4_CFLAGS="-I${path}/include/db4"
		DB4_VERSION="4"
	fi
	case "${DB4_VERSION}" in
	4)
		if [ -e "${path}/lib/db4" ]; then
			DB4_LIBS="-L${path}/lib/db4 -ldb"
		fi
		;;
	4.2)
		if [ -e "${path}/lib/db42" ]; then
			DB4_LIBS="-L${path}/lib/db42 -ldb"
		elif [ -e "${path}/lib/libdb-4.2.so" ]; then
			DB4_LIBS="-L${path}/lib -ldb-4.2"
		fi
		;;
	4.3)
		if [ -e "${path}/lib/db43" ]; then
			DB4_LIBS="-L${path}/lib/db43 -ldb"
		elif [ -e "${path}/lib/libdb-4.3.so" ]; then
			DB4_LIBS="-L${path}/lib -ldb-4.3"
		fi
		;;
	4.4)
		if [ -e "${path}/lib/db44" ]; then
			DB4_LIBS="-L${path}/lib/db44 -ldb"
		elif [ -e "${path}/lib/libdb-4.4.so" ]; then
			DB4_LIBS="-L${path}/lib -ldb-4.4"
		fi
		;;
	4.5)
		if [ -e "${path}/lib/db45" ]; then
			DB4_LIBS="-L${path}/lib/db45 -ldb"
		elif [ -e "${path}/lib/libdb-4.5.so" ]; then
			DB4_LIBS="-L${path}/lib -ldb-4.5"
		fi
		;;
	4.6)
		if [ -e "${path}/lib/db46" ]; then
			DB4_LIBS="-L${path}/lib/db46 -ldb"
		elif [ -e "${path}/lib/libdb-4.6.so" ]; then
			DB4_LIBS="-L${path}/lib -ldb-4.6"
		fi
		;;
	4.7)
		if [ -e "${path}/lib/db47" ]; then
			DB4_LIBS="-L${path}/lib/db47 -ldb"
		elif [ -e "${path}/lib/libdb-4.7.so" ]; then
			DB4_LIBS="-L${path}/lib -ldb-4.7"
		fi
		;;
	*)
		;;
	esac
done
EOF
	MkIf('"${DB4_VERSION}" != ""');
		MkPrint('yes, found ${DB4_VERSION}');
		MkTestVersion('DB4_VERSION', $ver);

		MkPrintN('checking whether DB4 works...');
		MkCompileC('HAVE_DB4', '${DB4_CFLAGS}', '${DB4_LIBS}', << 'EOF');
#include <db.h>
int main(int argc, char *argv[]) {
	DB *db;
	db_create(&db, NULL, 0);
	return (0);
}
EOF
		MkIf('"${HAVE_DB4}" != ""');
			MkSaveMK('DB4_CFLAGS', 'DB4_LIBS');
			MkSaveDefine('DB4_CFLAGS', 'DB4_LIBS');
		MkEndif;
	MkElse;
		MkPrint('no');
		MkSaveUndef('HAVE_DB4');
	MkEndif;
	return (0);
}

BEGIN
{
	$TESTS{'db4'} = \&Test;
	$DEPS{'db4'} = 'cc';
	$DESCR{'db4'} = 'Berkeley DB 4.x';
}

;1
