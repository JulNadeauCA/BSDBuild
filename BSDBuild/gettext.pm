# $Csoft: gettext.pm,v 1.6 2004/01/03 04:13:29 vedge Exp $
# vim:ts=4
#
# Copyright (c) 2003-2007 CubeSoft Communications, Inc.
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
	'/usr',
	'/usr/local',
	'/opt',
	'/opt/local',
);

sub Test
{
	my $test = << "EOF";
#include <libintl.h>
int main(int argc, char *argv[])
{
	char *s;
	bindtextdomain("foo", "/foo");
	textdomain("foo");
	s = gettext("string");
	s = dgettext("foo","string");
	return (0);
}
EOF
	MkDefine('GETTEXT_CFLAGS', '');
	MkDefine('GETTEXT_LIBS', '');

	MkCompileC('HAVE_GETTEXT', '${GETTEXT_CFLAGS}', '${GETTEXT_LIBS}', $test);
	MkIf('"${HAVE_GETTEXT}" = "no"');
		MkPrintN('checking whether gettext requires -lintl...');
		foreach my $pfx (@prefixes) {
			MkIf("-e $pfx/include/libintl.h");
			    MkDefine('GETTEXT_CFLAGS', "-I$pfx/include");
			    MkDefine('GETTEXT_LIBS', "-L$pfx/lib -lintl");
			MkEndif;
		}
		MkCompileC('HAVE_GETTEXT', '${GETTEXT_CFLAGS}', '${GETTEXT_LIBS}',
		    $test);
		MkIf('"${HAVE_GETTEXT}" = "yes"');
			MkSaveDefine('GETTEXT_CFLAGS', 'GETTEXT_LIBS');
			MkSaveMK('GETTEXT_CFLAGS', 'GETTEXT_LIBS');
		MkElse;
			MkPrintN('checking whether -lintl requires -liconv...');
			foreach my $pfx (@prefixes) {
				MkIf("-e $pfx/include/iconv.h");
				    MkDefine('GETTEXT_CFLAGS',
					    "\${GETTEXT_CFLAGS} -I$pfx/include");
				    MkDefine('GETTEXT_LIBS',
					    "\${GETTEXT_LIBS} -L$pfx/lib -liconv");
				MkEndif;
			}
			MkCompileC('HAVE_GETTEXT', '${GETTEXT_CFLAGS}', '${GETTEXT_LIBS}',
			    $test);
			MkIf('"${HAVE_GETTEXT}" != ""');
				MkSaveDefine('GETTEXT_CFLAGS', 'GETTEXT_LIBS');
				MkSaveMK('GETTEXT_CFLAGS', 'GETTEXT_LIBS');
			MkEndif;
		MkEndif;
	MkElse;
			MkSaveDefine('GETTEXT_CFLAGS', 'GETTEXT_LIBS');
			MkSaveMK('GETTEXT_CFLAGS', 'GETTEXT_LIBS');
	MkEndif;
}

BEGIN
{
	$DESCR{'gettext'} = 'a gettext library';
	$TESTS{'gettext'} = \&Test;
	$DEPS{'gettext'} = 'cc';
}

;1
