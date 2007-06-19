# $Csoft: opengl.pm,v 1.5 2004/03/10 16:33:36 vedge Exp $
# vim:ts=4
#
# Copyright (c) 2005 CubeSoft Communications, Inc.
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
	MkCompileC('_MK_HAVE_SYS_TYPES_H', '', '', << 'EOF');
#include <sys/types.h>
int main(int argc, char *argv[]) {
	size_t len = 1;
	ssize_t slen = 1;
	return (len>1?len:slen);
}
EOF
	MkIf('"${_MK_HAVE_SYS_TYPES_H}" = "yes"');
		MkPrintN('checking for unsigned typedefs...');
		MkCompileC('_MK_HAVE_UNSIGNED_TYPEDEFS', '', '', << 'EOF');
#include <sys/types.h>
int main(int argc, char *argv[]) {
	Uchar foo = 0;
	Uint bar = 0;
	Ulong baz = 0;
	foo = 1; bar = 2; baz = 3;
	return (0);
}
EOF
	MkElse;
		MkPrintN('checking for unsigned typedefs...');
		MkCompileC('_MK_HAVE_UNSIGNED_TYPEDEFS', '', '', << 'EOF');
int main(int argc, char *argv[]) {
	Uchar foo = 0;
	Uint bar = 0;
	Ulong baz = 0;
	foo = 1; bar = 2; baz = 3;
	return (0);
}
EOF
	MkEndif;
	return (0);
}

BEGIN
{
	$TESTS{'sys_types'} = \&Test;
	$DESCR{'sys_types'} = '<sys/types.h>';
}

;1
