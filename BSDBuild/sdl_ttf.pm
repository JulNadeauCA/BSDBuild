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
	
	MkExecPkgConfig($pfx, 'SDL_ttf', '--modversion', 'SDL_TTF_VERSION');
	MkExecPkgConfig($pfx, 'SDL_ttf', '--cflags', 'SDL_TTF_CFLAGS');
	MkExecPkgConfig($pfx, 'SDL_ttf', '--libs', 'SDL_TTF_LIBS');
	MkIfNE('${SDL_TTF_VERSION}', '');
		MkCompileC('HAVE_SDL_TTF', '${SDL_TTF_CFLAGS}', '${SDL_TTF_LIBS}', << 'EOF');
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <SDL.h>
#include <SDL_ttf.h>
int
main(int argc, char *argv[])
{
	TTF_Font	*fn;

	SDL_Init(0);

	fn = TTF_OpenFont(NULL, 10);

	SDL_Quit();
	return (0);
}
EOF
		MkSaveIfTrue('${HAVE_SDL_TTF}', 'SDL_TTF_CFLAGS', 'SDL_TTF_LIBS');
	MkElse;
		MkPrint('no');
		MkSaveUndef('HAVE_SDL_TTF');
	MkEndif;
	return (0);
}

BEGIN
{
	$DESCR{'sdl_ttf'} = 'SDL_ttf';
	$URL{'sdl_ttf'} = 'http://libsdl.org/projects/SDL_ttf';

	$TESTS{'sdl_ttf'} = \&Test;
	$DEPS{'sdl_ttf'} = 'cc,sdl';
}

;1
