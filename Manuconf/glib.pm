# $Csoft: glib.pm,v 1.1 2002/05/05 22:10:22 vedge Exp $
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
	print '# $Csoft$', "\n";

	my ($require, $ver) = @_;
	my $onfail = '';
	
	if ($require) {
		$onfail =
		    SHEcho("*** This package requires glib >= $ver") .
		    sHEcho("*** Get it from http://www.gtk.org/") .
		    SHFail("Missing glib");
	}
	
	print SHObtain('glib-config', '--version', 'GLIB_VERSION');
	print SHObtain('glib-config', '--cflags', 'GLIB_CFLAGS');
	print SHObtain('glib-config', '--libs', 'GLIB_LIBS');
	print SHObtain('glib12-config', '--version', 'GLIB12_VERSION');
	print SHObtain('glib12-config', '--cflags', 'GLIB12_CFLAGS');
	print SHObtain('glib12-config', '--libs', 'GLIB12_LIBS');
	
	print
	    SHTest('"$GLIB_VERSION" != ""',
	    SHDefine('GLIB_FOUND', 'yes') .
	        SHMKSave('GLIB_CFLAGS') .
	        SHMKSave('GLIB_LIBS'),
	    SHNothing());
	print
	    SHTest('"$GLIB12_VERSION" != ""',
	    SHDefine('GLIB_FOUND', 'yes') .
	        SHDefine('GLIB_CFLAGS', '$GLIB12_CFLAGS') .
	        SHDefine('GLIB_LIBS', '$GLIB12_LIBS') .
	        SHMKSave('GLIB_CFLAGS') .
	        SHMKSave('GLIB_LIBS'),
	    SHNothing());
	print
	    SHTest('"$GLIB_FOUND" = "yes"',
	    SHEcho('ok'),
	    SHEcho("missing") . $onfail);

	return (0);
}

BEGIN
{
	$TESTS{'glib'} = \&Test;
	$DESCR{'glib'} = 'Glib (http://www.gtk.org/)';
}

;1
