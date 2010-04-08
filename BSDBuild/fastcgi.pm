# $Csoft: fastcgi.pm,v 1.3 2004/01/03 04:13:29 vedge Exp $
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

my @prefixes = (
	'/usr/local',
	'/usr',
	'/opt/local',
	'/opt',
);

sub Test
{
	MkDefine('FASTCGI_CFLAGS', '');
	MkDefine('FASTCGI_LIBS', '');

	foreach my $dir (@prefixes) {
		MkIf("-e $dir/include/fcgi_stdio.h");
			MkDefine('FASTCGI_CFLAGS', "-I$dir/include");
		    MkDefine('FASTCGI_LIBS', "-L$dir/lib -lfcgi");
			MkBreak;
		MkEndif;
	}
	MkIf('"${FASTCGI_LIBS}" != ""');
		MkPrint('yes');
		MkPrintN('checking whether fastcgi works...');
		MkCompileC('HAVE_FASTCGI', '${FASTCGI_CFLAGS}', '${FASTCGI_LIBS}',
	           << 'EOF');
#include <fcgi_stdio.h>

int
main(int argc, char *argv[])
{
	printf("foo\n");
	return (0);
}
EOF
	MkElse;
		MkPrint('no');
	MkEndif;

	MkIf('"${HAVE_FASTCGI}" = "yes"');
		MkSaveMK('FASTCGI_CFLAGS', 'FASTCGI_LIBS');
		MkSaveDefine('FASTCGI_CFLAGS', 'FASTCGI_LIBS');
	MkElse;
		MkSaveUndef('HAVE_FASTCGI', 'FASTCGI_CFLAGS', 'FASTCGI_LIBS');
	MkEndif;
}

BEGIN
{
	$TESTS{'fastcgi'} = \&Test;
	$DEPS{'fastcgi'} = 'cc';
	$DESCR{'fastcgi'} = 'FastCGI (http://fastcgi.com)';
}
;1
