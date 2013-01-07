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
	'/usr/local/include',
);

my @autoLibDirs = (
	'/usr/local/X11/lib',
	'/usr/local/X11R6/lib',
	'/usr/local/X11R7/lib',
	'/usr/X11/lib',
	'/usr/X11R6/lib',
	'/usr/X11R7/lib',
	'/usr/local/lib',
);
	
my $testCode = << 'EOF';
#ifdef _USE_OPENGL_FRAMEWORK
# include <OpenGL/gl.h>
#else
# include <GL/gl.h>
#endif
int main(int argc, char *argv[]) {
	glFlush();
	glLoadIdentity();
	return (0);
}
EOF

sub Test
{
	my ($ver, $pfx) = @_;

	MkDefine('GL_CFLAGS', '');
	MkDefine('GL_LIBS', '');
	MkDefine('GL_FOUND', '');

	MkIfNE($pfx, '');
		MkIfExists("$pfx/include");
			MkDefine('GL_CFLAGS', "-I$pfx/include");
			MkDefine('GL_LIBS', "\${GL_LIBS} -L$pfx/lib");
			MkSetTrue('GL_FOUND');
		MkEndif;
	MkElse;
		MkCaseIn('${host}');
		MkCaseBegin('*-*-darwin*');
			MkPrintN('framework...');
			MkDefine('OPENGL_CFLAGS', '-D_USE_OPENGL_FRAMEWORK');
			MkDefine('OPENGL_LIBS', '-framework OpenGL');
			MkSetTrue('GL_FOUND');
			MkCaseEnd;
		MkCaseBegin('*');
			foreach my $dir (@autoIncludeDirs) {
				MkIfExists("$dir/GL");
					MkDefine('GL_CFLAGS', "-I$dir");
					MkSetTrue('GL_FOUND');
				MkEndif;
			}
			foreach my $dir (@autoLibDirs) {
				MkIfExists($dir);
					MkDefine('GL_LIBS', "\${GL_LIBS} -L$dir");
					MkSetTrue('GL_FOUND');
				MkEndif;
			}
			MkCaseEnd;
		MkEsac;
	MkEndif;

	MkIfTrue('${GL_FOUND}');
		MkPrint('yes');

		MkCaseIn('${host}');
		MkCaseBegin('*-*-darwin*');
			MkCaseEnd;
		MkCaseBegin('*-*-cygwin* | *-*-mingw32*');
			MkPrintN('checking whether -lopengl32 works...');
			MkCompileC('HAVE_LIBOPENGL32', '${OPENGL_CFLAGS}', '-lopengl32', $testCode);
			MkIfTrue('${HAVE_LIBOPENGL32}');
				MkDefine('OPENGL_LIBS', '${GL_LIBS} -lopengl32');
			MkElse;
				MkDefine('OPENGL_LIBS', '${GL_LIBS} -lGL');
			MkEndif;
			MkCaseEnd;
		MkCaseBegin('*');
			MkDefine('OPENGL_CFLAGS', '${GL_CFLAGS}');
			MkDefine('OPENGL_LIBS', '${GL_LIBS} -lGL');
			MkCaseEnd;
		MkEsac;

		MkPrintN('checking whether OpenGL works...');
		MkCompileC('HAVE_OPENGL', '${OPENGL_CFLAGS}', '${OPENGL_LIBS}', $testCode);
		MkIfTrue('${HAVE_OPENGL}');
			MkSave('OPENGL_CFLAGS', 'OPENGL_LIBS');
		MkElse;
			MkPrintN('checking whether -lGL requires -lm...');
			MkDefine('OPENGL_LIBS', '${OPENGL_LIBS} -lm');
			MkCompileC('HAVE_OPENGL', '${OPENGL_CFLAGS}', '${OPENGL_LIBS}', $testCode);
			MkSaveIfTrue('${HAVE_OPENGL}', 'OPENGL_CFLAGS', 'OPENGL_LIBS');
		MkEndif;
	MkElse;
		MkPrint('no');
	MkEndif;
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;
	
	if ($os =~ /^windows/) {
		MkEmulWindows('OPENGL', 'opengl32');
	} else {
		MkEmulUnavail('OPENGL');
	}
	return (1);
}

BEGIN
{
	$DESCR{'opengl'} = 'OpenGL (http://www.opengl.org)';
	$TESTS{'opengl'} = \&Test;
	$EMUL{'opengl'} = \&Emul;
	$DEPS{'opengl'} = 'cc';
}

;1
