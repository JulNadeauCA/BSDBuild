# $Csoft: freetype.pm,v 1.2 2002/09/06 00:56:51 vedge Exp $
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
	    Echo('yes'),
	    Fail('Could not find the FreeType library'));

	Define('CFLAGS', '${CFLAGS} ${FREETYPE_CFLAGS} ${FREETYPE_LIBS}');

	print NEcho('checking whether FreeType works...');
	TryLibCompile 'HAVE_FREETYPE',
	    '${FREETYPE_CFLAGS}', '${FREETYPE_LIBS}', << 'EOF';
#include <stdio.h>

#include <freetype/freetype.h>
#include <freetype/ftoutln.h>

int
main(int argc, char *argv[])
{
	FT_UInt uint;
	FT_Bitmap bitmap;
	FT_Face face;
	FT_Library library;
	FT_Error error;

	error = FT_Init_FreeType(&library);
	if (error) {
		return (1);
	}
	return (0);
}
EOF
	print
	    Cond('"${HAVE_FREETYPE}" = "yes"',
	    Nothing,
	    Fail('The FreeType test would not compile.'));

	return (0);
}

BEGIN
{
	$TESTS{'freetype'} = \&Test;
	$DESCR{'freetype'} = 'FreeType (http://www.freetype.org)';
}

;1
