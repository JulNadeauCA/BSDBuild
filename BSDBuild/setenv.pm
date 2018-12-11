# vim:ts=4
# Public domain

sub TEST_setenv
{
	TryCompile 'HAVE_SETENV', << 'EOF';
#include <stdlib.h>
int
main(int argc, char *argv[])
{
	(void)setenv("BSDBUILD_SETENV_TEST", "foo", 1);
	unsetenv("BSDBUILD_SETENV_TEST");
	return (0);
}
EOF
}

sub DISABLE_setenv
{
	MkDefine('HAVE_SETENV', 'no');
	MkSaveUndef('HAVE_SETENV');
}

BEGIN
{
	my $n = 'setenv';

	$DESCR{$n}   = '(un)setenv()';
	$TESTS{$n}   = \&TEST_setenv;
	$DISABLE{$n} = \&DISABLE_setenv;
	$DEPS{$n}    = 'cc';
}
;1
