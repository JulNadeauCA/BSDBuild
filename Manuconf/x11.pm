# $Csoft: x11.pm,v 1.16 2003/10/01 09:24:19 vedge Exp $
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

my @include_dirs = (
	'/usr/include/X11',
	'/usr/include/X11R6',
	'/usr/local/X11/include',
	'/usr/local/X11R6/include',
	'/usr/local/include/X11',
	'/usr/local/include/X11R6',
	'/usr/X11/include',
	'/usr/X11R6/include',
);

my @lib_dirs = (
	'/usr/local/X11/lib',
	'/usr/local/X11R6/lib',
	'/usr/X11/lib',
	'/usr/X11R6/lib',
);

sub Test
{
	print Define('x11_found_includes', 'no');
	print Define('x11_found_libs', 'no');

	foreach my $dir (@include_dirs) {
	    print Cond("-d $dir/X11",
		           Define('X11_CFLAGS', "\"-I$dir\"") .
				   Define('x11_found_includes', "yes"),
				   Nothing());
	}
	foreach my $dir (@lib_dirs) {
	    print Cond("-d $dir",
		           Define('X11_LIBS', "\"-L$dir\"") .
				   Define('x11_found_libs', "yes"),
				   Nothing());
	}

	TryLibCompile 'HAVE_X11', '${X11_CFLAGS}', '${X11_LIBS} -lX11', << 'EOF';
#include <X11/Xlib.h>

int
main(int argc, char *argv[])
{
	Display *disp;

	disp = XOpenDisplay(NULL);
	XCloseDisplay(disp);
	return (0);
}
EOF
	
	print Cond('"${HAVE_X11}" != ""',
			Define('x11_found', "yes") .
			    HDefine('HAVE_X11') .
			    MKSave('X11_CFLAGS') .
				MKSave('X11_LIBS'),
			Define('x11_found', "no") .
				HUndef('HAVE_X11'));
}

BEGIN
{
	$TESTS{'x11'} = \&Test;
	$DESCR{'x11'} = 'the X window system';
}

;1
