# vim:ts=4
#
# Copyright (c) 2008 Hypertriton, Inc. <http://hypertriton.com/>
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

my $testCode = << 'EOF';
#define _XOPEN_SOURCE 600
#include <stdlib.h>
int
main(int argc, char *argv[])
{
	long double ld;
	char *ep = NULL;
	char *foo = "1234";

	ld = strtold(foo, &ep);
	return (ld != 1234.0);
}
EOF

sub Test
{
	MkIfTrue('${HAVE_LONG_DOUBLE}');
		MkIfFalse('${HAVE_CYGWIN}');
			TryCompile('_MK_HAVE_STRTOLD', $testCode);
		MkElse;
			MkDefine('_MK_HAVE_STRTOLD', 'no');
			MkSaveUndef('_MK_HAVE_STRTOLD');
			MkPrint('not checking (cygwin issues)');
		MkEndif;
	MkElse;
		MkDefine('_MK_HAVE_STRTOLD', 'no');
		MkSaveUndef('_MK_HAVE_STRTOLD');
		MkPrint('skipping (no long double)');
	MkEndif;
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os eq 'linux' || $os eq 'darwin' || $os =~ /^(open|net|free)bsd$/) {
		MkDefine('_MK_HAVE_STRTOLD', 'yes');
		MkSaveDefine('_MK_HAVE_STRTOLD');
	} else {
		MkSaveUndef('_MK_HAVE_STRTOLD');
	}
	return (1);
}

BEGIN
{
	$DESCR{'strtold'} = 'a strtold() function';
	$TESTS{'strtold'} = \&Test;
	$EMUL{'strtold'} = \&Emul;
	$DEPS{'strtold'} = 'cc';
}

;1
