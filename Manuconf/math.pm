# $Csoft: sdl.pm,v 1.12 2002/12/27 02:27:16 vedge Exp $
# vim:ts=4
#
# Copyright (c) 2002 CubeSoft Communications, Inc. <http://www.csoft.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistribution of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Neither the name of CubeSoft Communications, nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
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

	print Define('MATH_LIBS', '-lm');
	TryLibCompile 'HAVE_MATH', '${CFLAGS}', '${MATH_LIBS}', << 'EOF';
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
	print
	    Cond('"${HAVE_MATH}" = "yes"',
	    MKSave('MATH_LIBS'),
	    Nothing());

	return (0);
}

BEGIN
{
	$TESTS{'math'} = \&Test;
	$DESCR{'math'} = 'the C math library';
}

;1
