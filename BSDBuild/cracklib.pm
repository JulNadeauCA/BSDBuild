# $Csoft: jpeg.pm,v 1.4 2004/01/03 04:13:29 vedge Exp $
# vim:ts=4
#
# Copyright (c) 2005 Hypertriton, Inc. <http://hypertriton.com/>
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

	MkDefine('CRACKLIB_CFLAGS', '');
	MkDefine('CRACKLIB_LIBS', '');

	MkIfNE($pfx, '');
		MkDefine('CRACKLIB_CFLAGS', "-I$pfx/include");
		MkDefine('CRACKLIB_LIBS', "-L$pfx/lib -lcrack");
	MkElse;
		foreach my $dir (@autoPrefixDirs) {
			MkIf("-f \"$dir/include/crack.h\"");
				MkDefine('CRACKLIB_CFLAGS', "-I$dir/include");
				MkDefine('CRACKLIB_LIBS', "-L$dir/lib -lcrack");
			MkEndif;
		}
	MkEndif;

	MkIfNE('${CRACKLIB_LIBS}', '');
		MkPrint('ok');
		MkPrintN('checking whether cracklib works...');
		MkCompileC('HAVE_CRACKLIB', '${CRACKLIB_CFLAGS}', '${CRACKLIB_LIBS}',
		    << 'EOF');
#include <stdio.h>
#include <crack.h>
int main(int argc, char *argv[]) {
	const char *msg = (const char *)FascistCheck("foobar", "/path");
	return (msg != NULL);
}
EOF
		MkSaveIfTrue('${HAVE_CRACKLIB}', 'CRACKLIB_CFLAGS', 'CRACKLIB_LIBS');
	MkElse;
		MkSaveUndef('HAVE_CRACKLIB');
		MkPrint('no');
	MkEndif;
	return (0);
}

BEGIN
{
	$DESCR{'cracklib'} = "cracklib";
	$DEPS{'cracklib'} = 'cc';
	$TESTS{'cracklib'} = \&Test;
}

;1
