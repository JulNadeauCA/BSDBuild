# vim:ts=4
#
# Copyright (c) 2003-2008 Hypertriton, Inc. <http://hypertriton.com/>
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
	'/usr',
	'/usr/local',
	'/opt',
	'/opt/local',
	'/usr/pkg'
);

my $testCode = << "EOF";
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <iconv.h>

int main(int argc, char *argv[])
{
	char *inbuf = "foo";
	size_t inlen = strlen(inbuf), rv;
	char *outbuf = malloc(3);
	size_t outbuflen = 3;
	iconv_t cd;

	cd = iconv_open("ISO-8859-1", "UTF-8");
	rv = iconv(cd, &inbuf, &inlen, &outbuf, &outbuflen);
	iconv_close(cd);
	return ((rv == (size_t)-1));
}
EOF

sub Test
{
	my ($ver, $pfx) = @_;

	MkDefine('ICONV_CFLAGS', '');
	MkDefine('ICONV_LIBS', '');
	
	MkIfNE($pfx, '');
		MkIfExists("$pfx/include/iconv.h");
		    MkDefine('ICONV_CFLAGS', "-I$pfx/include");
		    MkDefine('ICONV_LIBS', "-L$pfx/lib -liconv");
		MkEndif;
	MkElse;
		foreach my $dir (@autoPrefixDirs) {
			MkIfExists("$dir/include/iconv.h");
			    MkDefine('ICONV_CFLAGS', "-I$dir/include");
			    MkDefine('ICONV_LIBS', "-L$dir/lib -liconv");
			MkEndif;
		}
	MkEndif;
	MkCompileC('HAVE_ICONV', '${ICONV_CFLAGS} -Wno-cast-qual',
	           '${ICONV_LIBS}', $testCode);

	MkSaveIfTrue('${HAVE_ICONV}', 'ICONV_CFLAGS', 'ICONV_LIBS');
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;
	
	MkEmulUnavail('ICONV');
	MkEmulUnavailSYS('ICONV_CONST');
	return (1);
}

BEGIN
{
	$DESCR{'iconv'} = 'iconv()';
	$TESTS{'iconv'} = \&Test;
	$DEPS{'iconv'} = 'cc';
	$EMUL{'iconv'} = \&Emul;
}

;1
