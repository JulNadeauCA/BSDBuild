# vim:ts=4
#
# Copyright (c) 2007 Hypertriton, Inc. <http://hypertriton.com/>
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

my %autoIncludeDirs = (
	'/usr/include'				=> '/usr/lib',
	'/usr/local/include'		=> '/usr/local/lib',
	'/usr/include/X11'			=> '/usr/lib/X11',
	'/usr/include/X11R6'		=> '/usr/lib/X11R6',
	'/usr/local/X11/include'	=> '/usr/local/X11/lib',
	'/usr/local/X11R6/include'	=> '/usr/local/X11R6/lib',
	'/usr/local/include/X11'	=> '/usr/local/lib/X11',
	'/usr/local/include/X11R6'	=> '/usr/local/lib/X11R6',
	'/usr/X11/include'			=> '/usr/X11/lib',
	'/usr/X11R6/include'		=> '/usr/X11R6/lib',
);

sub Test
{
	my ($ver, $pfx) = @_;
	
	MkDefine('GLU_CFLAGS', '');
	MkDefine('GLU_LIBS', '');
	
	MkCaseIn('${host}');
	MkCaseBegin('*-*-darwin*');
		MkDefine('GLU_CFLAGS', '');
		MkDefine('GLU_LIBS', '-framework GLUT');
		MkCaseEnd;
	MkCaseBegin('*-*-cygwin* | *-*-mingw32*');
		MkIfNE($pfx, '');
			MkDefine('GLU_CFLAGS', "-I$pfx/include");
			MkDefine('GLU_LIBS', "-L$pfx/lib -lglu32");
		MkElse;
			MkDefine('GLU_CFLAGS', '');
			MkDefine('GLU_LIBS', '-lglu32');
		MkEndif;
		MkCaseEnd;
	MkCaseBegin('*');
		MkIfNE($pfx, '');
			MkIfExists("$pfx/include/GL/glu.h");
				MkDefine('GLU_CFLAGS', "-I$pfx/include");
				MkDefine('GLU_LIBS', "-L$pfx/lib -lGLU");
			MkEndif;
		MkElse;
			foreach my $dir (keys %autoIncludeDirs) {
				my $libDir = $autoIncludeDirs{$dir};
				MkIfExists("$dir/GL/glu.h");
					MkDefine('GLU_CFLAGS', "-I$dir");
					MkDefine('GLU_LIBS', "-L$libDir -lGLU");
					MkBreak;
				MkEndif;
			}
		MkEndif;
		MkCaseEnd;
	MkEsac;

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
	gluDeleteQuadric(qd);
	return (0);
}
EOF
	MkSaveIfTrue('${HAVE_GLU}', 'GLU_CFLAGS', 'GLU_LIBS');
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;
	
	if ($os =~ /^windows/) {
		MkEmulWindows('GLU', 'glu32');
	} else {
		MkEmulUnavail('GLU');
	}
	return (1);
}

BEGIN
{
	$DESCR{'glu'} = 'GLU';
	$URL{'glu'} = 'http://www.opengl.org';

	$TESTS{'glu'} = \&Test;
	$EMUL{'glu'} = \&Emul;
	$DEPS{'glu'} = 'cc,opengl,math';
}

;1
