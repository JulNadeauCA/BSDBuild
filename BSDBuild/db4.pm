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
DB4_PATH=""
for path in / /usr /usr/local /opt; do
	if [ -e "${path}/include/db4" ]; then
		DB4_PATH=${path}
	fi
done
DB4_CFLAGS="-I${DB4_PATH}/include/db4"
DB4_LIBS="-L${DB4_PATH}/lib/db4 -ldb"
EOF
	MkIf('"${DB4_PATH}" != ""');
		MkPrint('yes');
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
	$DESCR{'db4'} = 'Berkeley DB 4 (http://www.sleepycat.com)';
}

;1
