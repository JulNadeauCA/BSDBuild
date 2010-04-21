# $Csoft: opengl.pm,v 1.5 2004/03/10 16:33:36 vedge Exp $
# vim:ts=4
#
# Copyright (c) 2007 CubeSoft Communications, Inc.
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

sub Test
{
	my ($ver) = @_;
	
	print << 'EOF';
case "$host" in
*-*-darwin*)
	GLU_CFLAGS=""
	GLU_LIBS="-framework GLUT"
	;;
*-*-cygwin* | *-*-mingw32*)
	GLU_CFLAGS=""
	GLU_LIBS="-lglu32"
	;;
*)
	GLU_CFLAGS=""
EOF
		foreach my $dir (@include_dirs) {
			MkIf qq{-d "$dir/GL/glu.h"};
				MkDefine('GLU_CFLAGS', "-I$dir");
				print "break\n";
			MkEndif;
		}
print << 'EOF';
	GLU_LIBS="-lGLU"
	;;
esac
EOF

	MkCompileC('HAVE_GLU', '${OPENGL_CFLAGS} ${GLU_CFLAGS}',
	                       '${OPENGL_LIBS} ${GLU_LIBS} ${MATH_LIBS}', << 'EOF');
#ifdef __APPLE__
#include <OpenGL/gl.h>
#include <OpenGL/glu.h>
#else
#include <GL/gl.h>
#include <GL/glu.h>
#endif
int main(int argc, char *argv[]) {
	GLUquadric *qd;
	qd = gluNewQuadric();
	return (0);
}
EOF

	MkIf '"${HAVE_GLU}" = "yes"';
		MkSaveMK('GLU_CFLAGS', 'GLU_LIBS');
		MkSaveDefine('GLU_CFLAGS', 'GLU_LIBS');
	MkElse;
		MkSaveUndef('GLU_CFLAGS', 'GLU_LIBS');
	MkEndif;
	return (0);
}

sub Link
{
	my $lib = shift;

	if ($lib ne 'glu') {
		return (0);
	}
	PmIfHDefined('HAVE_GLU');
		if ($EmulOS eq 'windows') {
			PmLink('glu32');
		} else {
			PmLink('GLU');
		}
		if ($EmulEnv =~ /^cb-/) {
			PmIncludePath('$(#GLU.include)');
			PmLibPath('$(#GLU.lib)');
		}
	PmEndif;
	return (1);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;
	
	if ($os eq 'darwin') {
		MkDefine('GLU_CFLAGS', '');
		MkDefine('GLU_LIBS', '-framework GLUT');
	} elsif ($os eq 'windows') {
		MkDefine('GLU_CFLAGS', '');
		MkDefine('GLU_LIBS', 'glu32');
	} else {
		MkDefine('GLU_CFLAGS', '-I/usr/X11R6/include');
		MkDefine('GLU_LIBS', '-lGLU');
	}
	MkDefine('HAVE_GLU', 'yes');
	MkSaveDefine('HAVE_GLU', 'GLU_CFLAGS', 'GLU_LIBS');
	MkSaveMK('GLU_CFLAGS', 'GLU_LIBS');
	return (1);
}

BEGIN
{
	$DESCR{'glu'} = 'GLU (http://www.opengl.org)';
	$TESTS{'glu'} = \&Test;
	$LINK{'glu'} = \&Link;
	$EMUL{'glu'} = \&Emul;
	$DEPS{'glu'} = 'cc,opengl,math';
}

;1
