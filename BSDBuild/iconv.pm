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
#include <errno.h>
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
	if (rv == (size_t)-1 && errno == E2BIG) {
	}
	iconv_close(cd);
	return (0);
}
EOF

my $testConstCode = << "EOF";
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <iconv.h>

int main(int argc, char *argv[])
{
	const char *inbuf = "foo";
	size_t inlen = strlen(inbuf), rv;
	char *outbuf = malloc(3);
	size_t outbuflen = 3;
	iconv_t cd;

	cd = iconv_open("ISO-8859-1", "UTF-8");
	rv = iconv(cd, &inbuf, &inlen, &outbuf, &outbuflen);
	if (rv == (size_t)-1 && errno == E2BIG) {
	}
	iconv_close(cd);
	return (0);
}
EOF

sub Test
{
	my ($ver, $pfx) = @_;

	MkDefine('ICONV_CFLAGS', '');
	MkDefine('ICONV_LIBS', '');

	MkCompileC('HAVE_ICONV',
	           '${ICONV_CFLAGS} -Wno-cast-qual',
	           '${ICONV_LIBS}', $testCode);
	MkIfFalse('${HAVE_ICONV}');
		MkPrintN('checking for iconv() in -liconv...');
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
		MkIfTrue('${HAVE_ICONV}');
			MkPrintN('checking for iconv() in -liconv (const)...');
			MkCompileC('HAVE_ICONV', '${ICONV_CFLAGS} -Wno-cast-qual',
			           '${ICONV_LIBS}', $testConstCode);
		MkEndif;
	MkElse;
			MkPrintN('checking for iconv() with const...');
			MkCompileC('HAVE_ICONV', '${ICONV_CFLAGS} -Wno-cast-qual',
			           '${ICONV_LIBS}', $testConstCode);
	MkEndif;
		
	MkSave('ICONV_CFLAGS', 'ICONV_LIBS');

	# Test for const-correctness
	MkIfTrue('${HAVE_ICONV}');
		MkPrintN('checking whether iconv() is const-correct...');
		MkCompileC('HAVE_ICONV_CONST', '${ICONV_CFLAGS} -Wcast-qual -Werror',
		           '${ICONV_LIBS}', $testConstCode);
	MkElse;
		MkSaveUndef('HAVE_ICONV_CONST');
	MkEndif;
}

BEGIN
{
	$DESCR{'iconv'} = 'iconv()';
	$TESTS{'iconv'} = \&Test;
	$DEPS{'iconv'} = 'cc';
}

;1
