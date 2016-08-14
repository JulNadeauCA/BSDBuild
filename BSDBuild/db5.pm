# vim:ts=4
#
# Copyright (c) 2016 Hypertriton, Inc. <http://hypertriton.com/>
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

my @db5_releases = ('5.0', '5.1', '5.2', '5.3');

my $testCode = << 'EOF';
#include <db5/db.h>
#if DB_VERSION_MAJOR != 5
#error version
#endif
int main(int argc, char *argv[]) {
	DB *db;
	db_create(&db, NULL, 0);
	return (0);
}
EOF

sub Test
{
	my ($ver, $pfx) = @_;

	print << "EOF";
DB5_CFLAGS=''
DB5_LIBS=''
DB5_VERSION=''

for path in $pfx /usr /usr/local /opt; do
EOF

	foreach my $dbRel (@db5_releases) {
		print << "EOF";
	if [ -e "\${path}/lib/db5/libdb-$dbRel.so" ]; then
		DB5_LIBS="-L\${path}/lib/db5 -ldb-$dbRel"
		DB5_CFLAGS="-I\${path}/include/db5 -I\${path}/include"
		DB5_VERSION='$dbRel'
		break
	fi
EOF
	}
	print "done\n";

	MkIfFound($pfx, $ver, 'DB5_VERSION');
		MkPrintSN('checking whether DB5 works...');
		MkCompileC('HAVE_DB5', '${DB5_CFLAGS}', '${DB5_LIBS}', $testCode);
		MkSaveIfTrue('${HAVE_DB5}', 'DB5_CFLAGS', 'DB5_LIBS');
	MkElse;
		MkSaveUndef('HAVE_DB5');
	MkEndif;
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;
	
	MkEmulUnavail('DB5');
	return (1);
}

BEGIN
{
	$DESCR{'db5'} = 'Berkeley DB 5';
	$URL{'db5'} = 'http://www.oracle.com/technology/products/berkeley-db';

	$TESTS{'db5'} = \&Test;
	$DEPS{'db5'} = 'cc';
	$EMUL{'db5'} = \&Emul;
}

;1
