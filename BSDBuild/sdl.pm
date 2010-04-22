# vim:ts=4
#
# Copyright (c) 2002-2010 Hypertriton, Inc. <http://hypertriton.com/>
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

sub Test
{
	my ($ver) = @_;
	my $testCode = << 'EOF';
#include <stdio.h>
#include <SDL.h>
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

print << 'EOF';
case "${host}" in
*-*-darwin*)
EOF
	MkExecOutput('sdl-config', '--version', 'SDL_VERSION');
	MkExecOutput('sdl-config', '--cflags', 'SDL_CFLAGS');
	MkExecOutput('sdl-config', '--libs', 'SDL_LIBS');
print << 'EOF';
	;;
*-*-freebsd*)
EOF
	# The FreeBSD packages installs `sdl11-config'.
	MkExecOutput('sdl11-config', '--version', 'SDL_VERSION');
	MkIf('"${SDL_VERSION}" != ""');
		MkExecOutput('sdl11-config', '--cflags', 'SDL_CFLAGS');
		MkExecOutput('sdl11-config', '--libs', 'SDL_LIBS');
	MkElse;
		MkExecOutput('sdl-config', '--version', 'SDL_VERSION');
		MkExecOutput('sdl-config', '--cflags', 'SDL_CFLAGS');
		MkExecOutput('sdl-config', '--libs', 'SDL_LIBS');
	MkEndif;
print << 'EOF';
	;;
*)
EOF
	MkExecOutput('sdl-config', '--version', 'SDL_VERSION');
	MkExecOutput('sdl-config', '--cflags', 'SDL_CFLAGS');
	MkExecOutput('sdl-config', '--libs', 'SDL_LIBS');
print << 'EOF';
	;;
esac
EOF

	MkIf('"${SDL_VERSION}" != ""');
		MkPrint('yes, found ${SDL_VERSION}');
		MkTestVersion('SDL_VERSION', $ver);

		MkPrintN('checking whether SDL works...');
		MkCompileC('HAVE_SDL', '${SDL_CFLAGS}', '${SDL_LIBS}', $testCode);
		MkIf('"${HAVE_SDL}" != "no"');
			MkSaveMK('SDL_CFLAGS', 'SDL_LIBS');
			MkSaveDefine('SDL_CFLAGS', 'SDL_LIBS');
		MkElse;
			MkPrintN('checking whether SDL works (with X11 libs)...');
			MkAppend('SDL_LIBS', '-L/usr/X11R6/lib -lX11 -lXext -lXrandr '.
			                     '-lXrender');
			MkCompileC('HAVE_SDL', '${SDL_CFLAGS}', '${SDL_LIBS}', $testCode);
			MkIf('"${HAVE_SDL}" != "no"');
				MkSaveMK('SDL_CFLAGS', 'SDL_LIBS');
				MkSaveDefine('SDL_CFLAGS', 'SDL_LIBS');
			MkElse;
				MkSaveUndef('SDL_CFLAGS', 'SDL_LIBS');
			MkEndif;
		MkEndif;
	MkElse;
		MkPrint('no');
		MkSaveUndef('HAVE_SDL', 'SDL_CFLAGS', 'SDL_LIBS');
	MkEndif;
	return (0);
}

sub Link
{
	my $lib = shift;

	if ($lib ne 'SDL' && $lib ne 'SDLmain') {
		return (0);
	}
	PmIfHDefined('HAVE_SDL');
		PmLink('SDL');
		PmLink('SDLmain');
		if ($EmulEnv =~ /^cb-/) {
			PmIncludePath('$(#sdl.include)');
			PmLibPath('$(#sdl.lib)');
		}
	PmEndif;
	return (1);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os eq 'darwin') {
		MkDefine('SDL_CFLAGS', '-I/opt/local/include/SDL -I/opt/local/include '.
		                       '-I/usr/local/include/SDL -I/usr/local/include '.
		                       '-I/usr/include/SDL -I/usr/include '.
		                       '-D_GNU_SOURCE=1 -D_THREAD_SAFE');
		MkDefine('SDL_LIBS', '-L/usr/lib -L/opt/local/lib -L/usr/local/lib '.
		                     '-lSDLmain -lSDL -Wl,-framework,Cocoa');
	} elsif ($os eq 'windows') {
		MkDefine('SDL_CFLAGS', '');
		MkDefine('SDL_LIBS', 'SDL SDLmain');
	} else {
		MkDefine('SDL_CFLAGS', '-I/usr/include/SDL -I/usr/include '.
		                       '-I/usr/local/include/SDL -I/usr/local/include '.
		                       '-I/usr/X11R6/include/SDL -I/usr/X11R6/include '.
		                       '-D_GNU_SOURCE=1 -D_REENTRANT');
		MkDefine('SDL_LIBS', '-lSDL -lpthread');
	}
	MkDefine('HAVE_SDL', 'yes');
	MkSaveDefine('HAVE_SDL', 'SDL_CFLAGS', 'SDL_LIBS');
	MkSaveMK('SDL_CFLAGS', 'SDL_LIBS');
	return (1);
}

BEGIN
{
	$DESCR{'sdl'} = 'SDL (http://www.libsdl.org)';
	$EMUL{'sdl'} = \&Emul;
	$TESTS{'sdl'} = \&Test;
	$LINK{'sdl'} = \&Link;
	$DEPS{'sdl'} = 'cc';
}

;1
