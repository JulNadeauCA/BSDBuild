# $Csoft: x11.pm,v 1.1 2002/05/05 22:10:22 vedge Exp $
#
# Copyright (c) 2002 CubeSoft Communications <http://www.csoft.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistribution of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistribution in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of CubeSoft Communications, nor the names of its
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
	my $require = shift;
	print '# $Csoft$', "\n";

	while ($dir = shift(@_)) {
	    print
	        SHTest("-d $dir",
		SHDefine('X11BASE', $dir) .
		    SHDefine('CONF_X11', 1) .
		    SHDefine('X11_CFLAGS', "-I$dir/include") .
		    SHDefine('X11_LIBS', "-L$dir/lib"),
		SHNothing());
	}
	print
	    SHTest('"$X11BASE" != ""',
	    SHNEcho('ok') . SHEcho('$X11BASE') .
		SHHSave('CONF_X11') .
	        SHMKSave('X11BASE') .
	        SHMKSave('X11_CFLAGS') .
	        SHMKSave('X11_LIBS'),
	    SHRequire('X11R6', '3', 'http://www.xfree86.org/'));
}

BEGIN
{
	$TESTS{'x11'} = \&Test;
	$DESCR{'x11'} = 'X11 (http://www.xfree86.org/)';
}

;1
