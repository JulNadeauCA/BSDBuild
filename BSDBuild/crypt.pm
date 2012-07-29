# vim:ts=4
#
# Copyright (c) 2012 Hypertriton, Inc. <http://hypertriton.com/>
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
#include <unistd.h>

int
main(int argc, char *argv[])
{
	char *key = "some key", *salt = "sa";
	char *enc;

	if ((enc = crypt(key, salt)) != NULL) {
		return (1);
	}
	return (0);
}
EOF

sub Test
{
	MkDefine('CRYPT_CFLAGS', '');
	MkDefine('CRYPT_LIBS', '');

	TryCompileFlagsC('HAVE_CRYPT', '-lcrypt', $testCode);
	MkIfTrue('${HAVE_CRYPT}');
		MkDefine('CRYPT_CFLAGS', '');
		MkDefine('CRYPT_LIBS', '-lcrypt');
	MkElse;
		MkPrintN('checking for crypt() in libc...');
		TryCompileFlagsC('HAVE_CRYPT', '', $testCode);
		MkIfTrue('${HAVE_CRYPT}');
			MkDefine('CRYPT_CFLAGS', '');
			MkDefine('CRYPT_LIBS', '');
		MkEndif;
	MkEndif;

	MkSave('CRYPT_CFLAGS', 'CRYPT_LIBS');
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os eq 'linux' || $os eq 'darwin' || $os =~ /^(open|net|free)bsd$/) {
		MkDefine('HAVE_CRYPT', 'yes');
		MkSaveDefine('HAVE_CRYPT');
	} else {
		MkSaveUndef('HAVE_CRYPT');
	}
	MkDefine('CRYPT_CFLAGS', '');
	MkDefine('CRYPT_LIBS', '');
	MkSave('CRYPT_CFLAGS', 'CRYPT_LIBS');
	return (1);
}

BEGIN
{
	$DESCR{'crypt'} = 'the crypt() routine (in -lcrypt)';
	$TESTS{'crypt'} = \&Test;
	$EMUL{'crypt'} = \&Emul;
	$DEPS{'crypt'} = 'cc';
}

;1
