# $Csoft: jpeg.pm,v 1.3 2003/10/01 09:24:19 vedge Exp $
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

	print Define('JPEG_CFLAGS', '-I/usr/local/include');
	print Define('JPEG_LIBS', '"-L/usr/local/lib -ljpeg"');
	print Echo("ok");
	
	print NEcho('checking whether libjpeg works...');
	TryLibCompile 'HAVE_JPEG',
	    '${JPEG_CFLAGS}', '${JPEG_LIBS}', << 'EOF';
#include <stdio.h>
#include <jpeglib.h>

struct jpeg_error_mgr		jerr;
struct jpeg_compress_struct	jcomp;

int
main(int argc, char *argv[])
{
	jcomp.err = jpeg_std_error(&jerr);

	jpeg_create_compress(&jcomp);
	jcomp.image_width = 32;
	jcomp.image_height = 32;
	jcomp.input_components = 3;
	jcomp.in_color_space = JCS_RGB;

	jpeg_set_defaults(&jcomp);
	jpeg_set_quality(&jcomp, 75, TRUE);

	jpeg_destroy_compress(&jcomp);
	return (0);
}
EOF

	print
		Cond('"${HAVE_JPEG}" != ""',
		MKSave('JPEG_CFLAGS') .
		MKSave('JPEG_LIBS'),
		Nothing());

	return (0);
}

BEGIN
{
	$HOMEPAGE = 'ftp://ftp.uu.net/graphics/jpeg/';
	$DESCR{'jpeg'} = "libjpeg ($HOMEPAGE)";
	$TESTS{'jpeg'} = \&Test;
}

;1
