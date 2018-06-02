# vim:ts=4
#
# Copyright (c) 2011-2018 Julien Nadeau Carriere <vedge@hypertriton.com>
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

	MkIfPkgConfig('xinerama');
		MkExecPkgConfig($pfx, 'xinerama', '--modversion', 'XINERAMA_VERSION');
		MkExecPkgConfig($pfx, 'xinerama', '--cflags', 'XINERAMA_CFLAGS');
		MkExecPkgConfig($pfx, 'xinerama', '--libs', 'XINERAMA_LIBS');
	MkElse;
		MkDefine('XINERAM_CFLAGS', '');
		MkDefine('XINERAMA_LIBS', '');
		MkIfNE($pfx, '');
			MkIfExists("$pfx/include/X11");
			    MkDefine('XINERAMA_CFLAGS', "-I$pfx/include");
			MkEndif;
			MkIfExists("$pfx/lib");
			    MkDefine('XINERAMA_LIBS', "-L$pfx/lib");
			MkEndif;
		MkElse;
			my @autoIncludeDirs = (
				'/usr/include/X11',
				'/usr/include/X11R6',
				'/usr/local/X11/include',
				'/usr/local/X11R6/include',
				'/usr/local/include/X11',
				'/usr/local/include/X11R6',
				'/usr/X11/include',
				'/usr/X11R6/include',
			);
			my @autoLibDirs = (
				'/usr/local/X11/lib',
				'/usr/local/X11R6/lib',
				'/usr/X11/lib',
				'/usr/X11R6/lib',
			);
			foreach my $dir (@autoIncludeDirs) {
				MkIfExists("$dir/X11");
				    MkDefine('XINERAMA_CFLAGS', "-I$dir");
				MkEndif;
			}
			foreach my $dir (@autoLibDirs) {
				MkIfExists($dir);
				    MkDefine('XINERAMA_LIBS', "\${XINERAMA_LIBS} -L$dir");
				MkEndif;
			}
#			MkIfNE('${XINERAMA_CFLAGS}', '');
#				MkPrintS("trying autodetected path");
#				MkPrintS("WARNING: You should probably use --with-xinerama=prefix");
#			MkEndif;
		MkEndif;
		MkDefine('XINERAMA_LIBS', "\${XINERAMA_LIBS} -lXinerama");
	MkEndif;

	MkCompileC('HAVE_XINERAMA', '${X11_CFLAGS} ${XINERAMA_CFLAGS}',
	                            '${X11_LIBS} ${XINERAMA_LIBS}', << 'EOF');
#include <X11/Xlib.h>
#include <X11/extensions/Xinerama.h>

int main(int argc, char *argv[])
{
	Display *disp;
	int event_base = 0, error_base = 0;
	int rv = 1;

	disp = XOpenDisplay(NULL);
	if (XineramaQueryExtension(disp, &event_base, &error_base)) {
		rv = 0;
	}
	XCloseDisplay(disp);
	return (rv);
}
EOF
	MkSaveIfTrue('${HAVE_XINERAMA}', 'XINERAMA_CFLAGS', 'XINERAMA_LIBS');

	MkIfTrue('${HAVE_XINERAMA}');
		MkDefine('XINERAMA_PC', 'xinerama');
	MkElse;
		MkDefine('XINERAMA_PC', '');
	MkEndif;
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;
	
	MkEmulUnavail('XINERAMA');
	return (1);
}

BEGIN
{
	$DESCR{'xinerama'} = 'the Xinerama extension';
	$URL{'xinerama'} = 'http://x.org';

	$TESTS{'xinerama'} = \&Test;
	$EMUL{'xinerama'} = \&Emul;
	$DEPS{'xinerama'} = 'cc,x11';
}

;1
