# $Csoft: sdl.pm,v 1.6 2002/07/31 00:28:03 vedge Exp $
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
	my ($ver) = @_;
	
	print Obtain('freetype-config', '--version', 'FREETYPE_VERSION');
	print Obtain('freetype-config', '--cflags', 'FREETYPE_CFLAGS');
	print Obtain('freetype-config', '--libs', 'FREETYPE_LIBS');

	print
	    Cond('"${FREETYPE_VERSION}" != ""',
	    Define('freetype_found', 'yes') .
	        MKSave('FREETYPE_CFLAGS') .
	        MKSave('FREETYPE_LIBS'),
	    Nothing());
	print
	    Cond('"${freetype_found}" = "yes"',
	    Echo('ok'),
	    Fail('Missing FreeType'));

	return (0);
}

BEGIN
{
	$TESTS{'freetype'} = \&Test;
	$DESCR{'freetype'} = 'FreeType (http://www.freetype.org)';
}

;1
