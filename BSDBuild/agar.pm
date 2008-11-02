# $Csoft: agar.pm,v 1.7 2005/09/27 00:29:42 vedge Exp $
# vim:ts=4
#
# Copyright (c) 2004 CubeSoft Communications, Inc.
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
	
	MkExecOutputUnique('agar-config', '--version', 'AGAR_VERSION');
	MkIf('"${AGAR_VERSION}" != ""');
		MkPrint('yes');
		MkExecOutput('agar-config', '--cflags', 'AGAR_CFLAGS');
		MkExecOutput('agar-config', '--libs', 'AGAR_LIBS');
		MkSaveMK('AGAR_CFLAGS', 'AGAR_LIBS');
		MkSaveDefine('AGAR_CFLAGS', 'AGAR_LIBS');
	MkElse;
	    MkPrint('no');
		MkSaveUndef('AGAR_CFLAGS', 'AGAR_LIBS');
	MkEndif;

	MkPrintN('checking whether Agar works...');
	MkCompileC('HAVE_AGAR', '${AGAR_CFLAGS}', '${AGAR_LIBS}', << 'EOF');
#include <agar/core.h>
#include <agar/gui.h>

int
main(int argc, char *argv[])
{
	AG_InitCore("conf-test", 0);
	AG_InitVideo(320, 240, 32, 0);
	AG_EventLoop();
	AG_Quit();
	return (0);
}
EOF
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os eq 'darwin') {
		MkDefine('AGAR_CFLAGS', '-I/opt/local/include/agar '.
		                       '-I/opt/local/include '.
		                       '-I/usr/local/include/agar '.
							   '-I/usr/local/include '.
		                       '-I/usr/include/agar -I/usr/include '.
		                       '-D_THREAD_SAFE');
		MkDefine('AGAR_LIBS', '-L/usr/lib -L/opt/local/lib -L/usr/local/lib '.
		                      '-L/usr/X11R6/lib '.
		                      '-lag_gui -lag_core -lSDL -lGL -lpthread '.
							  '-lfreetype');
	} elsif ($os eq 'windows') {
		MkDefine('AGAR_CFLAGS', '');
		MkDefine('AGAR_LIBS', 'ag_core ag_gui');
	} else {
		MkDefine('AGAR_CFLAGS', '-I/usr/include/agar -I/usr/include '.
		                        '-I/usr/local/include/agar '.
							    '-I/usr/local/include ');
		MkDefine('AGAR_LIBS', '-L/usr/local/lib -lag_gui -lag_core -lSDL '.
		                      '-lpthread -lfreetype -lz -L/usr/X11R6/lib '.
							  '-lGL -lm');
	}
	MkDefine('HAVE_AGAR', 'yes');
	MkSaveDefine('HAVE_AGAR', 'AGAR_CFLAGS', 'AGAR_LIBS');
	MkSaveMK('AGAR_CFLAGS', 'AGAR_LIBS');
	return (1);
}

sub Link
{
	my $var = shift;

	if ($var eq 'ag_core') {
		PmLink('ag_core');
		PmLink('SDL');

		if ($EmulEnv =~ /^cb-/) {
			PmIncludePath('$(#agar.include)');
			PmIncludePath('$(#sdl.include)');
			PmLibPath('$(#agar.lib)');
			PmLibPath('$(#sdl.lib)');
		}
		return (1);
	}

	if ($var eq 'ag_gui') {
		PmLink('ag_gui');
		PmLink('SDL');
		if ($EmulOS eq 'windows') {
			PmLink('opengl32');
		} else {
			PmLink('GL');
		}
		PmLink('freetype');
		
		if ($EmulEnv =~ /^cb-/) {
			PmIncludePath('$(#agar.include)');
			PmIncludePath('$(#sdl.include)');
			PmIncludePath('$(#gl.include)');
			PmIncludePath('$(#freetype.include)');
			PmLibPath('$(#agar.lib)');
			PmLibPath('$(#sdl.lib)');
			PmLibPath('$(#gl.lib)');
			PmLibPath('$(#freetype.lib)');
		}
		return (1);
	}

	return (0);
}

BEGIN
{
	$TESTS{'agar'} = \&Test;
	$DEPS{'agar'} = 'cc';
	$LINK{'agar'} = \&Link;
	$EMUL{'agar'} = \&Emul;
	$DESCR{'agar'} = 'Agar (http://libagar.org/)';
}

;1
