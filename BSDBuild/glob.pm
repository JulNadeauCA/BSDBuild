# Public domain

sub TEST_glob
{
	TryCompile 'HAVE_GLOB', << 'EOF';
#include <string.h>
#include <glob.h>
#include <stdio.h>

int
main(int argc, char *argv[])
{
	glob_t gl;
	int rv, i;
	char *s = NULL;

	rv = glob("~/foo", GLOB_TILDE, NULL, &gl);
	for (i = 0; i < gl.gl_pathc; i++) { s = gl.gl_pathv[i]; }
	return (rv != 0 && s != NULL);
}
EOF
}

sub DISABLE_glob
{
	MkDefine('HAVE_GLOB', 'no');
	MkSaveUndef('HAVE_GLOB');
}

BEGIN
{
	my $n = 'glob';

	$DESCR{$n}   = 'glob()';
	$TESTS{$n}   = \&TEST_glob;
	$DISABLE{$n} = \&DISABLE_glob;
	$DEPS{$n}    = 'cc';
}
;1
