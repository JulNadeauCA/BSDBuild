# Public domain

my @autoIncludeAndLibDirs = (
	'/usr/include:/usr/lib',
	'/usr/local/include:/usr/local/lib',
	'/usr/include/X11:/usr/lib/X11',
	'/usr/include/X11R6:/usr/lib/X11R6',
	'/usr/local/X11/include:/usr/local/X11/lib',
	'/usr/local/X11R6/include:/usr/local/X11R6/lib',
	'/usr/local/include/X11:/usr/local/lib/X11',
	'/usr/local/include/X11R6:/usr/local/lib/X11R6',
	'/usr/X11/include:/usr/X11/lib',
	'/usr/X11R6/include:/usr/X11R6/lib',
);

sub TEST_glu
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
			foreach my $dirspec (@autoIncludeAndLibDirs) {
				my ($dir, $libDir) = split(':', $dirspec);
				MkIfExists("$dir/GL/glu.h");
					MkDefine('GLU_CFLAGS', "-I$dir");
					MkDefine('GLU_LIBS', "-L$libDir -lGLU");
				MkEndif;
			}
		MkEndif;
		MkCaseEnd;
	MkEsac;

	MkCompileC('HAVE_GLU',
	           '${OPENGL_CFLAGS} ${GLU_CFLAGS}',
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
	MkIfFalse('${HAVE_GLU}');
		MkDisableFailed('glu');
	MkEndif;
}

sub DISABLE_glu
{
	MkDefine('HAVE_GLU', 'no') unless $TestFailed;
	MkDefine('GLU_CFLAGS', '');
	MkDefine('GLU_LIBS', '');
	MkSaveUndef('HAVE_GLU');
}

BEGIN
{
	my $n = 'glu';

	$DESCR{$n}   = 'GLU';
	$URL{$n}     = 'http://www.opengl.org';
	$TESTS{$n}   = \&TEST_glu;
	$DISABLE{$n} = \&DISABLE_glu;
	$DEPS{$n}    = 'cc,opengl';
	$SAVED{$n}   = 'GLU_CFLAGS GLU_LIBS';
}
;1
