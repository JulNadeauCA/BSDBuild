# $Csoft: sdl.pm,v 1.18 2004/09/12 14:21:11 vedge Exp $
# vim:ts=4
#
# Copyright (c) 2005 CubeSoft Communications, Inc.
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
	
	print ReadOut('sdl-config', '--version', 'sdl_version');
	print ReadOut('sdl-config', '--cflags', 'SDL_CFLAGS');
	print ReadOut('sdl-config', '--static-libs', 'SDL_LIBS');
	
	# Mac OS X port
	print ReadOut('sdl-config', '--libs', 'SDL_LIBS_SHORT');
	print << 'EOF';
if [ "$SYSTEM" = "Darwin" ]; then
	SDL_LIBS=$SDL_LIBS_SHORT
fi
EOF

print << 'EOF';
SDL_IMAGE_CFLAGS="$SDL_CFLAGS"
SDL_IMAGE_LIBS="$SDL_LIBS -lSDL_image"
EOF

	print
	    Cond('"${sdl_version}" != ""',
	    Define('sdl_found', 'yes') .
	    MKSave('SDL_IMAGE_CFLAGS') .
	    MKSave('SDL_IMAGE_LIBS') ,
	    Nothing());
	print
	    Cond('"${sdl_found}" = "yes"',
	    Echo('ok'),
	    Fail('Could not find the SDL library. Is sdl-config in $PATH?'));
	
	print NEcho('checking whether SDL_image works...');
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
	print
	    Cond('"${HAVE_SDL_IMAGE}" = "yes"',
	    HDefineStr('SDL_IMAGE_LIBS') .
	    HDefineStr('SDL_IMAGE_CFLAGS'),
		HUndef('SDL_IMAGE_LIBS') .
		HUndef('SDL_IMAGE_CFLAGS') .
	    Fail('The SDL_image test would not compile.'));

	print << 'EOF';
echo "#ifndef SDL_IMAGE_LIBS" > config/sdl_image_libs.h
echo "#define SDL_IMAGE_LIBS \"${SDL_IMAGE_LIBS}\"" >> config/sdl_image_libs.h
echo "#endif /* SDL_IMAGE_LIBS */" >> config/sdl_image_libs.h
EOF
	print << 'EOF';
echo "#ifndef SDL_IMAGE_CFLAGS" > config/sdl_image_cflags.h
echo "#define SDL_IMAGE_CFLAGS \"${SDL_IMAGE_CFLAGS}\"" >> config/sdl_image_cflags.h
echo "#endif /* SDL_IMAGE_CFLAGS */" >> config/sdl_image_cflags.h
EOF
	return (0);
}

BEGIN
{
	$TESTS{'sdl_image'} = \&Test;
	$DESCR{'sdl_image'} = 'SDL_image (http://www.libsdl.org/projects/SDL_image)';
}

;1
