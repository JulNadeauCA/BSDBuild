# $Csoft: opengl.pm,v 1.5 2004/03/10 16:33:36 vedge Exp $
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

my @include_dirs = (
	'/usr/include/X11',
	'/usr/include/X11R6',
	'/usr/local/X11/include',
	'/usr/local/X11R6/include',
	'/usr/local/include/X11',
	'/usr/local/include/X11R6',
	'/usr/X11/include',
	'/usr/X11R6/include',
);

my @lib_dirs = (
	'/usr/local/X11/lib',
	'/usr/local/X11R6/lib',
	'/usr/X11/lib',
	'/usr/X11R6/lib',
);

sub Test
{
	my ($ver) = @_;
	my $code = << 'EOF';
#ifdef __APPLE__
#include <OpenGL/gl.h>
#else
#include <GL/gl.h>
#endif
int main(int argc, char *argv[]) {
	glFlush();
	glLoadIdentity();
	return (0);
}
EOF

	MkDefine('GL_CFLAGS', '');
	MkDefine('GL_LIBS', '');

	foreach my $dir (@include_dirs) {
		MkIf qq{-d "$dir/GL"};
			MkDefine('GL_CFLAGS', "-I$dir");
		MkEndif;
	}
	foreach my $dir (@lib_dirs) {
		MkIf qq{-d "$dir"};
			MkDefine('GL_LIBS', "-L$dir");
		MkEndif;
	}
	MkPrint('yes');

	MkIf q{"$SYSTEM" = "Darwin"};
		MkDefine('OPENGL_CFLAGS', '');
		MkDefine('OPENGL_LIBS', '-framework OpenGL');
	MkElse;
		MkDefine('OPENGL_CFLAGS', '${GL_CFLAGS}');
		
		MkPrintN('checking whether -lopengl32 works...');
		MkCompileC('HAVE_LIBOPENGL32', '${OPENGL_CFLAGS}', '-lopengl32', $code);
		MkIf '"${HAVE_LIBOPENGL32}" = "yes"';
			MkDefine('OPENGL_LIBS', '${GL_LIBS} -lopengl32');
		MkElse;
			MkDefine('OPENGL_LIBS', '${GL_LIBS} -lGL');
		MkEndif;
	MkEndif;

	MkPrintN('checking whether OpenGL works...');
	MkCompileC('HAVE_OPENGL', '${OPENGL_CFLAGS}', '${OPENGL_LIBS}', $code);
	MkIf '"${HAVE_OPENGL}" = "yes"';
		MkSaveMK('OPENGL_CFLAGS', 'OPENGL_LIBS');
		MkSaveDefine('OPENGL_CFLAGS', 'OPENGL_LIBS');
	MkElse;
		MkPrintN('checking whether -lGL requires -lm...');
		MkDefine('OPENGL_LIBS', '${OPENGL_LIBS} -lm');
		MkCompileC('HAVE_OPENGL', '${OPENGL_CFLAGS}', '${OPENGL_LIBS}', $code);
		MkIf '"${HAVE_OPENGL}" = "yes"';
			MkSaveMK('OPENGL_CFLAGS', 'OPENGL_LIBS');
			MkSaveDefine('OPENGL_CFLAGS', 'OPENGL_LIBS');
		MkElse;
			MkSaveUndef('OPENGL_CFLAGS', 'OPENGL_LIBS');
		MkEndif;
	MkEndif;
	return (0);
}

sub Link
{
	my $lib = shift;

	if ($lib eq 'opengl') {
			print << 'EOF';
if (hdefs["HAVE_OPENGL"] ~= nil) then
	if (windows) then
		tinsert(package.links, { "opengl32" })
	else
		tinsert(package.links, { "GL" })
	end
end
EOF
		return (1);
	}
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;
	
	if ($os eq 'darwin') {
		MkDefine('OPENGL_CFLAGS', '');
		MkDefine('OPENGL_LIBS', '-framework OpenGL');
	} elsif ($os eq 'windows') {
		MkDefine('OPENGL_CFLAGS', '');
		MkDefine('OPENGL_LIBS', 'opengl32');
	} elsif ($os eq 'linux' || $os =~ /^(open|net|free)bsd$/) {
		MkDefine('OPENGL_CFLAGS', '-I/usr/X11R6/include');
		MkDefine('OPENGL_LIBS', '-lGL');
	} else {
		goto UNAVAIL;
	}
	MkDefine('HAVE_OPENGL', 'yes');
	MkSaveDefine('HAVE_OPENGL', 'OPENGL_CFLAGS', 'OPENGL_LIBS');
	MkSaveMK('OPENGL_CFLAGS', 'OPENGL_LIBS');
	return (1);
UNAVAIL:
	MkDefine('HAVE_OPENGL', 'no');
	MkSaveUndef('HAVE_OPENGL');
	MkSaveMK('OPENGL_CFLAGS', 'OPENGL_LIBS');
	return (1);
}

BEGIN
{
	$DESCR{'opengl'} = 'OpenGL (http://www.opengl.org)';
	$TESTS{'opengl'} = \&Test;
	$EMUL{'opengl'} = \&Emul;
	$LINK{'opengl'} = \&Link;
	$DEPS{'opengl'} = 'cc';
}

;1
