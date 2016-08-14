# vim:ts=4
#
# Copyright (c) 2005-2010 Hypertriton, Inc. <http://hypertriton.com/>
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
	my ($ver, $pfx) = @_;
	
	MkExecPkgConfig($pfx, 'SDL_image', '--modversion', 'SDL_IMAGE_VERSION');
	MkExecPkgConfig($pfx, 'SDL_image', '--cflags', 'SDL_IMAGE_CFLAGS');
	MkExecPkgConfig($pfx, 'SDL_image', '--libs', 'SDL_IMAGE_LIBS');
	MkIfNE('${SDL_IMAGE_VERSION}', '');
		MkCompileC('HAVE_SDL_IMAGE', '${SDL_IMAGE_CFLAGS}', '${SDL_IMAGE_LIBS}', << 'EOF');
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <SDL.h>
#include <SDL_image.h>
int
main(int argc, char *argv[])
{
	SDL_Surface *image;
	SDL_Init(0);
	image = IMG_Load(NULL);
	SDL_Quit();
	return (0);
}
EOF
		MkSaveIfTrue('${HAVE_SDL_IMAGE}', 'SDL_IMAGE_CFLAGS', 'SDL_IMAGE_LIBS');
	MkElse;
		MkPrintS('no');
		MkSaveUndef('HAVE_SDL_IMAGE');
	MkEndif;
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

#	if ($os =~ /^windows/) {
#		MkEmulWindows('SDL_IMAGE', 'SDL_image');
#	} else {
		MkEmulUnavail('SDL_IMAGE');
#	}
	return (1);
}

BEGIN
{
	$DESCR{'sdl_image'} = 'SDL_image';
	$URL{'sdl_image'} = 'http://libsdl.org/projects/SDL_image';

	$TESTS{'sdl_image'} = \&Test;
	$DEPS{'sdl_image'} = 'cc,sdl';
	$EMUL{'sdl_image'} = \&Emul;
}

;1
