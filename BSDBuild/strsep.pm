# Public domain

sub TEST_strsep
{
	TryCompile 'HAVE_STRSEP', << 'EOF';
#include <string.h>
int
main(int argc, char *argv[])
{
	char foo[32], *pFoo = &foo[0];
	char *s;

	foo[0] = '\0';
	s = strsep(&pFoo, " ");
	return (s != NULL);
}
EOF
}

sub DISABLE_strsep
{
	MkDefine('HAVE_STRSEP', 'no');
	MkSaveUndef('HAVE_STRSEP');
}

BEGIN
{
	my $n = 'strsep';

	$DESCR{$n}   = 'strsep()';
	$TESTS{$n}   = \&TEST_strsep;
	$DISABLE{$n} = \&DISABLE_strsep;
	$DEPS{$n}    = 'cc';
}
;1
