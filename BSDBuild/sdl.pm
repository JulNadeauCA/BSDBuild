# $Csoft: sdl.pm,v 1.17 2004/03/10 16:33:36 vedge Exp $
# vim:ts=4
#
# Copyright (c) 2002-2007 Hypertriton, Inc. <http://hypertriton.com/>
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
	
	MkIf('"${SYSTEM}" = "Darwin"');
		MkExecOutput('sdl-config', '--version', 'SDL_VERSION');
		MkExecOutput('sdl-config', '--cflags', 'SDL_CFLAGS');
		MkExecOutput('sdl-config', '--libs', 'SDL_LIBS');
	MkElif('"${SYSTEM}" = "FreeBSD"');
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
	MkElse;
		MkExecOutput('sdl-config', '--version', 'SDL_VERSION');
		MkExecOutput('sdl-config', '--cflags', 'SDL_CFLAGS');
		MkExecOutput('sdl-config', '--libs', 'SDL_LIBS');
	MkEndif;
	
	MkIf('"${SDL_VERSION}" != ""');
		MkPrint('yes');
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
	my @inclpaths = ();
	my @libpaths = ();

	if ($lib ne 'SDL' && $lib ne 'SDLmain') {
		return (0);
	}

	if ($EmulEnv =~ /^cb-(gcc|ow)$/) {
		if ($EmulOS eq 'windows') {
			@inclpaths = ('C:\\\\MinGW\\\\include\\\\SDL',
			              'C:\\\\MinGW\\\\include',
			              'C:\\\\Program Files\\\\SDL\\\\include');
			@libpaths = ('C:\\\\MinGW\\\\lib\\\\SDL',
			             'C:\\\\MinGW\\\\lib',
			             'C:\\\\Program Files\\\\SDL\\\\lib');
		} else {
			@inclpaths = ('/usr/local/include/SDL',
			              '/usr/include/SDL',
						  '/usr/local/include',
			              '/usr/include');
			@libpaths = ('/usr/local/lib', '/usr/lib');
		}
	}

	print 'if (hdefs["HAVE_SDL"] ~= nil) then'."\n";
	print 'table.insert(package.links, { "SDL", "SDLmain" })'."\n";
	foreach my $path (@inclpaths) {
		print "table.insert(package.includepaths,{\"$path\"})\n";
	}
	foreach my $path (@libpaths) {
		print "table.insert(package.libpaths,{\"$path\"})\n";
	}
	print "end\n";
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
	} elsif ($os eq 'linux' || $os =~ /^(open|net|free)bsd$/) {
		MkDefine('SDL_CFLAGS', '-I/usr/include/SDL -I/usr/include '.
		                       '-I/usr/local/include/SDL -I/usr/local/include '.
		                       '-I/usr/X11R6/include/SDL -I/usr/X11R6/include '.
		                       '-D_GNU_SOURCE=1 -D_REENTRANT');
		MkDefine('SDL_LIBS', '-lSDL -lpthread');
	} else {
		goto UNAVAIL;
	}
	MkDefine('HAVE_SDL', 'yes');
	MkSaveDefine('HAVE_SDL', 'SDL_CFLAGS', 'SDL_LIBS');
	MkSaveMK('SDL_CFLAGS', 'SDL_LIBS');
	return (1);
UNAVAIL:
	MkDefine('HAVE_SDL', 'no');
	MkSaveUndef('HAVE_SDL');
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
