# $Csoft$
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

my @autoPrefixDirs = (
	'/usr/local',
	'/usr'
);

sub Test
{
	my ($ver, $pfx) = @_;

	MkDefine('ZLIB_CFLAGS', '');
	MkDefine('ZLIB_LIBS', '');

	MkIfNE($pfx, '');
		MkDefine('ZLIB_CFLAGS', "-I$pfx/include");
		MkDefine('ZLIB_LIBS', "-L$pfx/lib -lz");
	MkElse;
		foreach my $dir (@autoPrefixDirs) {
			MkIf("-f \"$dir/include/zlib.h\"");
				MkDefine('ZLIB_CFLAGS', "-I$dir/include");
				MkDefine('ZLIB_LIBS', "-L$dir/lib -lz");
			MkEndif;
		}
	MkEndif;
		
	MkIfNE('${ZLIB_LIBS}', '');
		MkPrintS('ok');
		MkPrintSN('checking whether zlib works...');
		MkCompileC('HAVE_ZLIB', '${ZLIB_CFLAGS}', '${ZLIB_LIBS}',
		    << 'EOF');
#include <stdio.h>
#include <string.h>
#include <zlib.h>

int main(int argc, char *argv[]) {
	z_stream strm;
	strm.zalloc = Z_NULL;
	strm.zfree = Z_NULL;
	strm.opaque = Z_NULL;
	return deflateInit(&strm, 0);
}
EOF
		MkSaveIfTrue('${HAVE_ZLIB}', 'ZLIB_CFLAGS', 'ZLIB_LIBS');
	MkElse;
		MkSaveUndef('HAVE_ZLIB');
		MkPrintS('no');
	MkEndif;
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	MkEmulUnavail('ZLIB');
	return (1);
}

BEGIN
{
	$DESCR{'zlib'} = "zlib";
	$DEPS{'zlib'} = 'cc';
	$TESTS{'zlib'} = \&Test;
	$EMUL{'zlib'} = \&Emul;
}

;1
