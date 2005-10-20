# $Csoft: sdl.pm,v 1.17 2004/03/10 16:33:36 vedge Exp $
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
	
	MkIf('"${SYSTEM}" = "Darwin"');
		# Use --libs with the OSX port.
		MkExecOutput('sdl-config', '--version', 'SDL_VERSION');
		MkExecOutput('sdl-config', '--cflags', 'SDL_CFLAGS');
		MkExecOutput('sdl-config', '--libs', 'SDL_LIBS');
	MkElif('"${SYSTEM}" = "FreeBSD"');
		# The FreeBSD packages installs `sdl11-config'.
		MkExecOutput('sdl11-config', '--version', 'SDL_VERSION');
		MkIf('"${SDL_VERSION}" != ""');
			MkExecOutput('sdl11-config', '--cflags', 'SDL_CFLAGS');
			MkExecOutput('sdl11-config', '--static-libs', 'SDL_LIBS');
		MkElse;
			MkExecOutput('sdl-config', '--version', 'SDL_VERSION');
			MkExecOutput('sdl-config', '--cflags', 'SDL_CFLAGS');
			MkExecOutput('sdl-config', '--static-libs', 'SDL_LIBS');
		MkEndif;
	MkElse;
		MkExecOutput('sdl-config', '--version', 'SDL_VERSION');
		MkExecOutput('sdl-config', '--cflags', 'SDL_CFLAGS');
		MkExecOutput('sdl-config', '--static-libs', 'SDL_LIBS');
	MkEndif;
	
	MkIf('"${SDL_VERSION}" != ""');
		MkPrint('yes');
		MkPrintN('checking whether SDL works...');
		MkCompileC('HAVE_SDL', '${SDL_CFLAGS}', '${SDL_LIBS}', << 'EOF');
#include <stdio.h>
#include <SDL.h>
int main(int argc, char *argv[]) {
	SDL_Surface su;
	SDL_TimerID tid;
	SDL_Color color;
	SDL_Event event;
	Uint32 u32;
	if (SDL_Init(SDL_INIT_TIMER|SDL_INIT_NOPARACHUTE) != 0) {
		return (1);
	}
	SDL_Quit();
	return (0);
}
EOF
		MkIf('"${HAVE_SDL}" != ""');
			MkSaveMK('SDL_CFLAGS', 'SDL_LIBS');
			MkSaveDefine('SDL_CFLAGS', 'SDL_LIBS');
		MkEndif;
	MkElse;
		MkPrint('no');
		MkSaveUndef('HAVE_SDL');
	MkEndif;
	return (0);
}

BEGIN
{
	$TESTS{'sdl'} = \&Test;
	$DESCR{'sdl'} = 'SDL (http://www.libsdl.org)';
}

;1
