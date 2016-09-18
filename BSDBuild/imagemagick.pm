# vim:ts=4
#
# Copyright (c) 2016 Hypertriton, Inc. <http://hypertriton.com/>
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

my $testCode = << 'EOF';
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <wand/MagickWand.h>

int
main(int argc, char *argv[])
{
	MagickWandGenesis();
	MagickWandTerminus();
	return (0);
}
EOF

sub Test
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'MagickWand-config', '--version', 'IMAGEMAGICK_VERSION');
	MkIfFound($pfx, $ver, 'IMAGEMAGICK_VERSION');
		MkPrintSN('checking whether ImageMagick works...');
		MkExecOutputPfx($pfx, 'MagickWand-config', '--cflags', 'IMAGEMAGICK_CFLAGS');
		MkExecOutputPfx($pfx, 'MagickWand-config', '--libs', 'IMAGEMAGICK_LIBS');
		MkCompileC('HAVE_IMAGEMAGICK',
		           '${IMAGEMAGICK_CFLAGS}', '${IMAGEMAGICK_LIBS}',
				   $testCode);
		MkSaveIfTrue('${HAVE_IMAGEMAGICK}', 'IMAGEMAGICK_CFLAGS', 'IMAGEMAGICK_LIBS');
	MkElse;
		MkSaveUndef('IMAGEMAGICK_CFLAGS', 'IMAGEMAGICK_LIBS');
	MkEndif;
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os =~ /^windows/) {
		MkEmulWindows('IMAGEMAGICK', 'MagickCore-6 MagickWand-6');
	} else {
		MkEmulUnavail('IMAGEMAGICK');
	}
	return (1);
}

BEGIN
{
	$DESCR{'imagemagick'} = 'ImageMagick';
	$URL{'imagemagick'} = 'http://www.ImageMagick.org';

	$TESTS{'imagemagick'} = \&Test;
	$DEPS{'imagemagick'} = 'cc';
	$EMUL{'imagemagick'} = \&Emul;
}

;1
