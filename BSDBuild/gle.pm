# vim:ts=4
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

sub TEST_gle
{
	my ($ver, $pfx) = @_;
	
	MkDefine('GLE_CFLAGS', '');
	MkDefine('GLE_LIBS', '');
	
	MkIfNE($pfx, '');
		MkIfExists("$pfx/include/GL/gle.h");
			MkDefine('GLE_CFLAGS', "-I$pfx/include");
			MkDefine('GLE_LIBS', "-L$pfx/lib -lgle");
		MkEndif;
	MkElse;
		foreach my $dirspec (@autoIncludeAndLibDirs) {
			my ($dir, $libDir) = split(':', $dirspec);
			MkIfExists("$dir/GL/gle.h");
				MkDefine('GLE_CFLAGS', "-I$dir");
				MkDefine('GLE_LIBS', "-L$libDir -lgle");
			MkEndif;
		}
	MkEndif;

	MkCompileC('HAVE_GLE', '${OPENGL_CFLAGS} ${GLE_CFLAGS} ${GLU_CFLAGS}',
	                       '${OPENGL_LIBS} ${GLE_LIBS} ${GLU_LIBS}', << 'EOF');
#ifdef __APPLE__
#include <OpenGL/gl.h>
#include <OpenGL/gle.h>
#else
#include <GL/gl.h>
#include <GL/gle.h>
#endif
int main(int argc, char *argv[]) {
	return gleGetNumSides();
}
EOF
	MkSaveIfTrue('${HAVE_GLE}', 'GLE_CFLAGS', 'GLE_LIBS');
}

sub DISABLE_gle
{
	MkDefine('HAVE_GLE', 'no');
	MkDefine('GLE_CFLAGS', '');
	MkDefine('GLE_LIBS', '');
	MkSaveUndef('HAVE_GLE', 'GLE_CFLAGS', 'GLE_LIBS');
}

sub EMUL_gle
{
	my ($os, $osrel, $machine) = @_;
	
	if ($os =~ /^windows/) {
		MkEmulWindows('GLE', 'gle');
	} else {
		MkEmulUnavail('GLE');
	}
	return (1);
}

BEGIN
{
	my $n = 'gle';

	$DESCR{$n}   = 'GLE';
	$URL{$n}     = 'http://linas.org/gle';
	$TESTS{$n}   = \&TEST_gle;
	$DISABLE{$n} = \&DISABLE_gle;
	$EMUL{$n}    = \&EMUL_gle;
	$DEPS{$n}    = 'cc,opengl,glu';
}
;1
