# $Csoft: jpeg.pm,v 1.4 2004/01/03 04:13:29 vedge Exp $
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

my @dirs = (
	'/usr/local',
	'/usr/X11R6',
	'/usr',
	'/opt/local',
	'/opt'
);

sub Test
{
	my ($ver) = @_;

	MkDefine('JPEG_CFLAGS', '');
	foreach my $dir (@dirs) {
		MkIf("-f \"$dir/include/jpeglib.h\"");
			MkDefine('JPEG_CFLAGS', "-I$dir/include");
			MkDefine('JPEG_LIBS', "-L$dir/lib -ljpeg");
		MkEndif;
	}
	MkIf('"${JPEG_CFLAGS}" != ""');
		MkPrint('ok');
		MkPrintN('checking whether libjpeg works...');
		MkCompileC('HAVE_JPEG', '${JPEG_CFLAGS}', '${JPEG_LIBS}', << 'EOF');
#ifdef _WIN32
#error "libjpeg conflicts with windows.h"
#endif

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
		MkIf('"${HAVE_JPEG}" != ""');
			MkSaveMK('JPEG_CFLAGS', 'JPEG_LIBS');
			MkSaveDefine('JPEG_CFLAGS', 'JPEG_LIBS');
		MkElse;
			MkSaveUndef('JPEG_CFLAGS', 'JPEG_LIBS');
		MkEndif;
	MkElse;
		MkSaveUndef('HAVE_JPEG');
		MkPrint('no');
	MkEndif;
	return (0);
}

sub Link
{
	my $lib = shift;

	if ($lib eq 'jpeg') {
			print << 'EOF';
if (hdefs["HAVE_JPEG"] ~= nil) then
	table.insert(package.links, { "jpeg" })
end
EOF
		return (1);
	}
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	MkDefine('HAVE_JPEG', 'no');
	MkDefine('JPEG_CFLAGS', '');
	MkDefine('JPEG_LIBS', '');

	MkSaveUndef('HAVE_JPEG');
	MkSaveMK('JPEG_CFLAGS', 'JPEG_LIBS');
	return (1);
}

BEGIN
{
	$DESCR{'jpeg'} = 'libjpeg (ftp://ftp.uu.net/graphics/jpeg/)';
	$TESTS{'jpeg'} = \&Test;
	$EMUL{'jpeg'} = \&Emul;
	$LINK{'jpeg'} = \&Link;
	$DEPS{'jpeg'} = 'cc';
}

;1
