# $Csoft: fastcgi.pm,v 1.1 2003/10/25 23:46:11 vedge Exp $
# vim:ts=4
#
# Copyright (c) 2002, 2003 CubeSoft Communications, Inc.
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

my @dirs = (
	'/usr/local',
	'/usr',
);

sub Test
{
	print Define('fastcgi_found', 'no');

	foreach my $dir (@dirs) {
	    print Cond("-e $dir/include/fcgi_stdio.h",
		           Define('FASTCGI_CFLAGS', "\"-I$dir/include\"") .
		           Define('FASTCGI_LIBS', "\"-L$dir/lib -lfcgi\"") .
				   Define('fastcgi_found', "yes"),
				   Nothing());
	}

	TryLibCompile 'HAVE_FASTCGI', '${FASTCGI_CFLAGS}', '${FASTCGI_LIBS}',
	    << 'EOF';
#include <fcgi_stdio.h>

int
main(int argc, char *argv[])
{
	printf("foo\n");
	return (0);
}
EOF
	
	print Cond('"${HAVE_FASTCGI}" != ""',
			Define('fastcgi_found', "yes") .
			    HDefine('HAVE_X11') .
			    MKSave('FASTCGI_CFLAGS') .
				MKSave('FASTCGI_LIBS'),
			Define('fastcgi_found', "no") .
				HUndef('HAVE_FASTCGI'));
}

BEGIN
{
	$TESTS{'fastcgi'} = \&Test;
	$DESCR{'fastcgi'} = 'FastCGI libraries (http://www.fastcgi.com)';
}

;1
