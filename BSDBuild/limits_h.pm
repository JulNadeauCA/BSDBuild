# vim:ts=4
#
# Copyright (c) 2007 CubeSoft Communications, Inc.
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
	MkCompileC('_MK_HAVE_LIMITS_H', '', '', << 'EOF');
#include <limits.h>

int main(int argc, char *argv[]) {
	int i;
	unsigned u;
	long l;
	unsigned long ul;

	i = INT_MIN;	i = INT_MAX;	u = UINT_MAX;
	l = LONG_MIN;	l = LONG_MAX;	ul = ULONG_MAX;
	return (0);
}
EOF

	MkPrintN('checking for FP definitions in <limits.h>...');
	MkCompileC('_MK_HAVE_LIMITS_H_FP', '', '', << 'EOF');
#include <limits.h>

int main(int argc, char *argv[]) {
	float f;
	double d;

	f = FLT_MIN;	f = FLT_MAX;
	d = DBL_MIN;	d = DBL_MAX;
	return (0);
}
EOF
	return (0);
}

BEGIN
{
	$TESTS{'limits_h'} = \&Test;
	$DESCR{'limits_h'} = '<limits.h>';
}

;1
