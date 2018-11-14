# Public domain
# vim:ts=4

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
			MkPrintSN('framework...');
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
		MkPrintS('yes');

		MkCaseIn('${host}');
		MkCaseBegin('*-*-darwin*');
			MkCaseEnd;
		MkCaseBegin('*-*-cygwin* | *-*-mingw32*');
			MkPrintSN('checking whether -lopengl32 works...');
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

		MkPrintSN('checking whether OpenGL works...');
		MkCompileC('HAVE_OPENGL', '${OPENGL_CFLAGS}', '${OPENGL_LIBS}', $testCode);
		MkIfTrue('${HAVE_OPENGL}');
			MkSave('OPENGL_CFLAGS', 'OPENGL_LIBS');
		MkElse;
			MkPrintSN('checking whether -lGL requires -lm...');
			MkDefine('OPENGL_LIBS', '${OPENGL_LIBS} -lm');
			MkCompileC('HAVE_OPENGL', '${OPENGL_CFLAGS}', '${OPENGL_LIBS}', $testCode);
			MkSaveIfTrue('${HAVE_OPENGL}', 'OPENGL_CFLAGS', 'OPENGL_LIBS');
		MkEndif;
	MkElse;
		MkPrintS('no');
	MkEndif;
	
	MkIfTrue('${HAVE_OPENGL}');
		MkDefine('OPENGL_PC', 'gl');
	MkElse;
		MkDefine('OPENGL_PC', '');
	MkEndif;
	return (0);
}

sub Disable
{
	MkDefine('OPENGL_PC', '');
	MkDefine('OPENGL_CFLAGS', '');
	MkDefine('OPENGL_LIBS', '');

	MkSaveUndef('HAVE_OPENGL', 'OPENGL_CFLAGS', 'OPENGL_LIBS');
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
	my $n = 'opengl';

	$DESCR{$n} = 'OpenGL';
	$URL{$n}   = 'http://www.opengl.org';

	$TESTS{$n}   = \&Test;
	$DISABLE{$n} = \&Disable;
	$EMUL{$n}    = \&Emul;

	$DEPS{$n} = 'cc';
}

;1
