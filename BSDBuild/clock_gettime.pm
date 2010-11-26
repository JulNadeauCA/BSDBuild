# vim:ts=4
#
# Copyright (c) 2010 Hypertriton, Inc. <http://hypertriton.com/>
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
#include <time.h>
int
main(int argc, char *argv[])
{
	struct timespec ts;
	clock_gettime(CLOCK_REALTIME, &ts);
	return (0);
}
EOF

sub Test
{
	MkDefine('CLOCK_CFLAGS', '');
	MkDefine('CLOCK_LIBS', '');

	MkCompileC('HAVE_CLOCK_GETTIME', '${CLOCK_CFLAGS}',
	    '${CLOCK_LIBS}', $testCode);
	MkIfTrue('${HAVE_CLOCK_GETTIME}');
		MkSaveDefine('HAVE_CLOCK_GETTIME', 'CLOCK_CFLAGS', 'CLOCK_LIBS');
		MkSaveMK('CLOCK_CFLAGS', 'CLOCK_LIBS');
	MkElse;
		MkPrintN('checking for clock_gettime() interface (with -lrt)...');
		MkDefine('CLOCK_LIBS', '-lrt');
		MkCompileC('HAVE_CLOCK_GETTIME', '${CLOCK_CFLAGS}', '${CLOCK_LIBS}', 
		    $testCode);
		MkIfTrue('${HAVE_CLOCK_GETTIME}');
			MkSaveDefine('HAVE_CLOCK_GETTIME', 'CLOCK_CFLAGS', 'CLOCK_LIBS');
			MkSaveMK('CLOCK_CFLAGS', 'CLOCK_LIBS');
		MkElse;
			MkSaveUndef('HAVE_CLOCK_GETTIME');
		MkEndif;
	MkEndif;
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	MkSaveUndef('HAVE_CLOCK_GETTIME');

	MkDefine('CLOCK_CFLAGS', '');
	MkDefine('CLOCK_LIBS', '');
	MkSave('CLOCK_CFLAGS', 'CLOCK_LIBS');
	return (1);
}

BEGIN
{
	$DESCR{'clock_gettime'} = 'clock_gettime() interface (w/o -lrt)';
	$TESTS{'clock_gettime'} = \&Test;
	$EMUL{'clock_gettime'} = \&Emul;
	$DEPS{'clock_gettime'} = 'cc';
}

;1
