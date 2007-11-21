# $Csoft: math.pm,v 1.3 2004/01/03 04:13:29 vedge Exp $
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

sub Test
{
	my ($ver) = @_;

	MkDefine('MATH_C99_LIBS', '-lm');
	MkDefine('MATH_C99_CFLAGS', '');
	MkCompileC('HAVE_MATH_C99', '${CFLAGS} ${MATH_C99_CFLAGS}',
	           '${MATH_C99_LIBS}',
	    << 'EOF');
#include <math.h>

int
main(int argc, char *argv[])
{
	float f = 1.0;
	double d = 1.0;

	d = fabs(d);
	f = fabsf(f);
	return (0);
}
EOF
	MkIf('"${HAVE_MATH_C99}" = "yes"');
	    MkSaveMK('MATH_C99_CFLAGS', 'MATH_C99_LIBS');
		MkSaveDefine('MATH_C99_CFLAGS', 'MATH_C99_LIBS');
	MkElse;
		MkSaveUndef('MATH_C99_LIBS');
	MkEndif;
	return (0);
}

BEGIN
{
	$TESTS{'math_c99'} = \&Test;
	$DESCR{'math_c99'} = 'the C math library (C99)';
}

;1
