# vim:ts=4
# Public domain

sub TEST_setlocale
{
	TryCompile 'HAVE_SETLOCALE', << 'EOF';
#include <locale.h>

int
main(int argc, char *argv[])
{
	setlocale(LC_ALL, "");
	return (0);
}
EOF
}

sub DISABLE_setlocale
{
	MkDefine('HAVE_SETLOCALE', 'no');
	MkSaveUndef('HAVE_SETLOCALE');
}

BEGIN
{
	my $n = 'setlocale';

	$DESCR{$n}   = 'setlocale()';
	$TESTS{$n}   = \&TEST_setlocale;
	$DISABLE{$n} = \&DISABLE_setlocale;
	$DEPS{$n}    = 'cc';
}
;1
