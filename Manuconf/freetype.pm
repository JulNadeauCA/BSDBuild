# $Csoft: freetype.pm,v 1.12 2004/03/10 16:33:36 vedge Exp $
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

sub Test
{
	my ($ver) = @_;

	# Ask freetype-config for compiler flags and libraries.
	print ReadOut('freetype-config', '--version', 'FREETYPE_VERSION');
	print ReadOut('freetype-config', '--cflags', 'FREETYPE_CFLAGS');
	print ReadOut('freetype-config', '--libs', 'FREETYPE_LIBS');

	# XXX IRIX package hack.
	print
	    Cond('-d /usr/freeware/include',
	    Define('FREETYPE_CFLAGS',
		'"${FREETYPE_CFLAGS} -I/usr/freeware/include"'),
	    Nothing());
	
	# Save the cflags/libs. Fail if FreeType is not installed.
	print
	    Cond('"${FREETYPE_VERSION}" != ""',
	    Define('freetype_found', 'yes') .
	    MKSave('FREETYPE_CFLAGS') .
	    MKSave('FREETYPE_LIBS') .
		Echo('yes') ,
	    Fail('Cannot find FreeType. Is freetype-config in your $PATH?'));

	# Try a test FreeType program.
	print NEcho('checking whether FreeType works...');
	TryLibCompile 'HAVE_FREETYPE',
	    '${FREETYPE_CFLAGS}', '${FREETYPE_LIBS}', << 'EOF';
#include <ft2build.h>
#include FT_FREETYPE_H
#include FT_OUTLINE_H

int
main(int argc, char *argv[])
{
	FT_UInt uint;
	FT_Bitmap bitmap;
	FT_Face face;
	FT_Library library;

	FT_Init_FreeType(&library);
	return (0);
}
EOF
	print
	    Cond('"${HAVE_FREETYPE}" = "yes"',
	    HDefineStr('FREETYPE_LIBS') .
		HDefineStr('FREETYPE_CFLAGS') ,
		HUndef('FREETYPE_LIBS') .
		HUndef('FREETYPE_CFLAGS') .
	    Fail('The FreeType test would not compile.'));

	return (0);
}

BEGIN
{
	$TESTS{'freetype'} = \&Test;
	$DESCR{'freetype'} = 'FreeType (http://www.freetype.org)';
}

;1
