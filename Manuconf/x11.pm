# $Csoft: x11.pm,v 1.10 2002/09/06 00:56:51 vedge Exp $
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

my @common_dirs = (
	'/usr/X11R6/include',
	'/usr/X11/include',
	'/usr/include/X11R6',
	'/usr/include/X11',
	'/usr/local/X11R6/include',
	'/usr/local/X11/include',
	'/usr/local/include/X11R6',
	'/usr/local/include/X11',
	'/usr/include',
	'/usr/local/include',
	'/usr/X386/include',
	'/usr/x386/include',
	'/usr/XFree86/include/X11',
	'/usr/athena/include',
	'/usr/openwin/include',
	'/usr/openwin/share/include');

sub Test
{
	foreach my $dir (@common_dirs) {
	    print
		    Cond("-d $dir/X11",
			    Define('X11_CFLAGS', "-I$dir"),
		        Nothing());
	}
	print
	    Cond('"${X11_CFLAGS}" != ""',
	        Echo('yes') .
		    Define('x11_found', "yes") . MKSave('X11_CFLAGS') ,
	        Fail('missing'));
}

BEGIN
{
	$TESTS{'x11'} = \&Test;
	$DESCR{'x11'} = 'the X window system';
}

;1
