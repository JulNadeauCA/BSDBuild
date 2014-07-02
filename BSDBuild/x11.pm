# vim:ts=4
#
# Copyright (c) 2002-2004 Hypertriton, Inc. <http://hypertriton.com/>
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

my @autoIncludeDirs = (
	'/usr/include/X11',
	'/usr/include/X11R6',
	'/usr/include/X11R7',
	'/usr/local/X11/include',
	'/usr/local/X11R6/include',
	'/usr/local/X11R7/include',
	'/usr/local/include/X11',
	'/usr/local/include/X11R6',
	'/usr/local/include/X11R7',
	'/usr/X11/include',
	'/usr/X11R6/include',
	'/usr/X11R7/include',
);

my @autoLibDirs = (
	'/usr/local/X11/lib',
	'/usr/local/X11R6/lib',
	'/usr/local/X11R7/lib',
	'/usr/X11/lib',
	'/usr/X11R6/lib',
	'/usr/X11R7/lib',
);

sub Test
{
	my ($ver, $pfx) = @_;

	MkIfPkgConfig('x11');
		MkExecPkgConfig($pfx, 'x11', '--modversion', 'X11_VERSION');
		MkExecPkgConfig($pfx, 'x11', '--cflags', 'X11_CFLAGS');
		MkExecPkgConfig($pfx, 'x11', '--libs', 'X11_LIBS');
	MkElse;
		MkDefine('X11_CFLAGS', '');
		MkDefine('X11_LIBS', '');
		MkIfNE($pfx, '');
			MkIfExists("$pfx/include/X11");
			    MkDefine('X11_CFLAGS', "-I$pfx/include");
			MkEndif;
			MkIfExists("$pfx/lib");
			    MkDefine('X11_LIBS', "-L$pfx/lib");
			MkEndif;
		MkElse;
			foreach my $dir (@autoIncludeDirs) {
				MkIfExists("$dir/X11");
				    MkDefine('X11_CFLAGS', "-I$dir");
				MkEndif;
			}
			foreach my $dir (@autoLibDirs) {
				MkIfExists($dir);
				    MkDefine('X11_LIBS', "\${X11_LIBS} -L$dir");
				MkEndif;
			}
#			MkIfNE('${X11_CFLAGS}', '');
#				MkPrint("trying autodetected path");
#				MkPrint("WARNING: You should probably use --with-x=prefix");
#			MkEndif;
		MkEndif;
	MkEndif;

	MkCompileC('HAVE_X11', '${X11_CFLAGS}', '${X11_LIBS} -lX11', << 'EOF');
#include <X11/Xlib.h>
int main(int argc, char *argv[])
{
	Display *disp;
	disp = XOpenDisplay(NULL);
	XCloseDisplay(disp);
	return (0);
}
EOF
	MkSaveIfTrue('${HAVE_X11}', 'X11_CFLAGS', 'X11_LIBS');

	MkIfTrue('${HAVE_X11}');
		MkPrintN('checking for the XKB extension...');
		MkCompileC('HAVE_XKB', '${X11_CFLAGS}', '${X11_LIBS} -lX11', << 'EOF');
#include <X11/Xlib.h>
#include <X11/XKBlib.h>
int main(int argc, char *argv[])
{
	Display *disp;
	KeyCode kc = 0;
	KeySym ks;
	disp = XOpenDisplay(NULL);
	ks = XkbKeycodeToKeysym(disp, kc, 0, 0);
	XCloseDisplay(disp);
	return (ks != NoSymbol);
}
EOF
	MkElse;
		MkSaveUndef('HAVE_XKB');
	MkEndif;
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	MkEmulUnavail('X11');
	return (1);
}

BEGIN
{
	$DESCR{'x11'} = 'the X window system';
	$URL{'x11'} = 'http://x.org';

	$TESTS{'x11'} = \&Test;
	$EMUL{'x11'} = \&Emul;
	$DEPS{'x11'} = 'cc';
}

;1
