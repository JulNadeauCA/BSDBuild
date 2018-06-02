# vim:ts=4
#
# Copyright (c) 2002-2018 Julien Nadeau Carriere <vedge@hypertriton.com>
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

use BSDBuild::Core;

my $testCode = << 'EOF';
#ifdef _USE_SDL_FRAMEWORK
# include <SDL/SDL.h>
# ifdef main
#  undef main
# endif
#else
# include <SDL.h>
#endif
int main(int argc, char *argv[]) {
	SDL_Surface *su;

	if (SDL_Init(SDL_INIT_TIMER|SDL_INIT_NOPARACHUTE) != 0) {
		return (1);
	}
	su = SDL_CreateRGBSurface(0, 16, 16, 32, 0, 0, 0, 0);
	SDL_FreeSurface(su);
	SDL_Quit();
	return (0);
}
EOF

sub Test
{
	my ($ver, $pfx) = @_;

	MkIfNE($pfx, '');
		MkExecOutputPfx($pfx, 'sdl-config', '--prefix', 'SDL_PREFIX');
		MkExecOutputPfx($pfx, 'sdl-config', '--version', 'SDL_VERSION');
		MkExecOutputPfx($pfx, 'sdl-config', '--cflags', 'SDL_CFLAGS');
		MkExecOutputPfx($pfx, 'sdl-config', '--libs', 'SDL_LIBS');
	MkElse;
		MkCaseIn('${host}');
		MkCaseBegin('*-*-darwin*');
			MkExecOutput('sdl-config', '--version', 'SDL_VERSION');
			MkIfNE('${SDL_VERSION}', '');
				MkExecOutput('sdl-config', '--prefix', 'SDL_PREFIX');
				MkExecOutput('sdl-config', '--cflags', 'SDL_CFLAGS');
				MkExecOutput('sdl-config', '--libs', 'SDL_LIBS');
			MkElse;
				MkPrintSN('framework...');
				MkDefine('SDL_VERSION', '1.2.15');
				MkDefine('SDL_CFLAGS', '-D_USE_SDL_FRAMEWORK');
				MkDefine('SDL_LIBS', '-framework SDL');
			MkEndif;
			MkCaseEnd;
		MkCaseBegin('*-*-freebsd*');
			MkExecOutput('sdl11-config', '--version', 'SDL_VERSION');
			MkIfNE('${SDL_VERSION}', '');
				MkExecOutput('sdl11-config', '--prefix', 'SDL_PREFIX');
				MkExecOutput('sdl11-config', '--cflags', 'SDL_CFLAGS');
				MkExecOutput('sdl11-config', '--libs', 'SDL_LIBS');
			MkElse;
				MkExecOutput('sdl-config', '--prefix', 'SDL_PREFIX');
				MkExecOutput('sdl-config', '--version', 'SDL_VERSION');
				MkExecOutput('sdl-config', '--cflags', 'SDL_CFLAGS');
				MkExecOutput('sdl-config', '--libs', 'SDL_LIBS');
			MkEndif;
			MkCaseEnd;
		MkCaseBegin('*');
			MkExecOutput('sdl-config', '--prefix', 'SDL_PREFIX');
			MkExecOutput('sdl-config', '--version', 'SDL_VERSION');
			MkExecOutput('sdl-config', '--cflags', 'SDL_CFLAGS');
			MkExecOutput('sdl-config', '--libs', 'SDL_LIBS');
			MkCaseEnd;
		MkEsac;
	MkEndif;
		
	MkIfFound($pfx, $ver, 'SDL_VERSION');
		MkPrintSN('checking whether SDL works...');
		MkCompileC('HAVE_SDL', '${SDL_CFLAGS}', '${SDL_LIBS}', $testCode);
		MkIfTrue('${HAVE_SDL}');
			MkCaseIn('${host}');
			MkCaseBegin('*-*-cygwin* | *-*-mingw32*');
				#
				# On Cygwin/MinGW, linking against -lSDL.dll is preferable 
				# to the output of `sdl-config`; use it if available.
				#
				MkIfExists('${SDL_PREFIX}/include/SDL');
					MkDefine('SDL_CFLAGS', '-I${SDL_PREFIX}/include/SDL -D_GNU_SOURCE=1');
				MkEndif;
				MkIfExists('${SDL_PREFIX}/lib/libSDL.dll.a');
					MkDefine('SDL_LIBS', '-L${SDL_PREFIX}/lib -lSDL.dll');
				MkEndif;
				MkCaseEnd;
			MkEsac;
			MkSave('SDL_CFLAGS', 'SDL_LIBS');
		MkElse;
			MkPrintSN('checking whether SDL works (with X11 libs)...');
			MkAppend('SDL_LIBS', '-L/usr/X11R6/lib -lX11 -lXext -lXrandr '.
			                     '-lXrender');
			MkCompileC('HAVE_SDL', '${SDL_CFLAGS}', '${SDL_LIBS}', $testCode);
			MkSaveIfTrue('${HAVE_SDL}', 'SDL_CFLAGS', 'SDL_LIBS');
		MkEndif;
	MkElse;
		MkSaveUndef('HAVE_SDL', 'SDL_CFLAGS', 'SDL_LIBS');
	MkEndif;

	MkIfTrue('${HAVE_SDL}');
		MkDefine('SDL_PC', 'sdl');
	MkElse;
		MkDefine('SDL_PC', '');
	MkEndif;
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os =~ /^windows/) {
		MkEmulWindows('SDL', 'SDL');
	} else {
		MkEmulUnavail('SDL');
	}
	return (1);
}

BEGIN
{
	$DESCR{'sdl'} = 'SDL';
	$URL{'sdl'} = 'http://www.libsdl.org';

	$EMUL{'sdl'} = \&Emul;
	$TESTS{'sdl'} = \&Test;
	$DEPS{'sdl'} = 'cc';
}

;1
