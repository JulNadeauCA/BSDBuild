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
	my ($ver) = @_;
	
	MkExecOutput('sdl-config', '--version', 'SDL_VERSION');
	MkExecOutput('sdl-config', '--cflags', 'SDL_CFLAGS');
	MkExecOutput('sdl-config', '--static-libs', 'SDL_LIBS');
	MkExecOutput('sdl-config', '--libs', 'SDL_LIBS_SHORT');

	print << 'EOF';
case "${host}" in
*-*-darwin*)
	SDL_LIBS="${SDL_LIBS_SHORT}"
	;;
*)
	;;
esac
EOF

	MkIf('"${SDL_VERSION}" != ""');
		MkDefine('SDL_IMAGE_CFLAGS', '$SDL_CFLAGS');
		MkDefine('SDL_IMAGE_LIBS', '-lSDL_image');
		MkCompileC('HAVE_SDL_IMAGE', '${SDL_IMAGE_CFLAGS}', '${SDL_IMAGE_LIBS}',
	               << 'EOF');
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
		MkIf('"${HAVE_SDL_IMAGE}" != "no"');
			MkSaveDefine('SDL_IMAGE_CFLAGS', 'SDL_IMAGE_LIBS');
			MkSaveMK	('SDL_IMAGE_CFLAGS', 'SDL_IMAGE_LIBS');
		MkEndif;
	MkElse;
		MkPrint('no');
		MkSaveUndef('HAVE_SDL_IMAGE');
	MkEndif;
	return (0);
}

BEGIN
{
	$DESCR{'sdl_image'} = 'SDL_image (http://libsdl.org/projects/SDL_image)';
	$TESTS{'sdl_image'} = \&Test;
	$DEPS{'sdl_image'} = 'cc,sdl';
}

;1
