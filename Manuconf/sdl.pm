# $Csoft: sdl.pm,v 1.14 2003/08/07 19:36:45 vedge Exp $
# vim:ts=4
#
# Copyright (c) 2002, 2003 CubeSoft Communications, Inc.
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

	# FreeBSD port
	print ReadOut('sdl11-config', '--version', 'sdl11_version');
	print ReadOut('sdl11-config', '--cflags', 'sdl11_cflags');
	print ReadOut('sdl11-config', '--static-libs', 'sdl11_libs');

	print
	    Cond('"${sdl_version}" != ""',
	    Define('sdl_found', 'yes') .
	        MKSave('SDL_CFLAGS') .
	        MKSave('SDL_LIBS'),
	    Nothing());
	print
	    Cond('"${sdl11_version}" != ""',
	    Define('sdl_found', 'yes') .
	        Define('SDL_CFLAGS', '$sdl11_cflags') .
	        Define('SDL_LIBS', '$sdl11_libs') .
	        MKSave('SDL_CFLAGS') .
	        MKSave('SDL_LIBS'),
	    Nothing());
	print
	    Cond('"${sdl_found}" = "yes"',
	    Echo('ok'),
	    Fail('Could not find the SDL library. '.
		     'Make sure sdl-config is in PATH.'));
	
	print NEcho('checking whether SDL works...');
	TryLibCompile 'HAVE_SDL',
	    '${SDL_CFLAGS}', '${SDL_LIBS}', << 'EOF';

#include <stdio.h>

#include <SDL.h>

int
main(int argc, char *argv[])
{
	SDL_Surface su;
	SDL_TimerID tid;
	SDL_Color color;
	SDL_Event event;
	Uint8 u8;
	Uint16 u16;
	Uint32 u32;
	Sint8 s8;
	Sint16 s16;
	Sint32 s32;

	if (SDL_Init(SDL_INIT_TIMER|SDL_INIT_NOPARACHUTE) != 0) {
		return (1);
	}
	SDL_Quit();
	return (0);
}

EOF
	print
	    Cond('"${HAVE_SDL}" = "yes"',
	    Nothing(),
	    Fail('The SDL test would not compile.'));

	return (0);
}

BEGIN
{
	$TESTS{'sdl'} = \&Test;
	$DESCR{'sdl'} = 'SDL (http://www.libsdl.org)';
}

;1
