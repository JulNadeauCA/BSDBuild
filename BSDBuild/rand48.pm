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

sub Test
{
	TryCompile 'HAVE_RAND48', << 'EOF';
#include <stdlib.h>
int
main(int argc, char *argv[])
{
	double d1, d2;
	unsigned short xbuf[3] = { 1,2,3 };
	unsigned short p[7];
	long l1, l2;
	d1 = drand48(); d2 = erand48(xbuf);
	l1 = lrand48(); l2 = nrand48(xbuf);
	srand48(l1);
	lcong48(p);
	return (0);
}
EOF
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	MkEmulUnavailSYS('RAND48');
	return (1);
}

BEGIN
{
	$TESTS{'rand48'} = \&Test;
	$DEPS{'rand48'} = 'cc';
	$EMUL{'rand48'} = \&Emul;
	$DESCR{'rand48'} = 'the rand48(3) family of functions';
}

;1