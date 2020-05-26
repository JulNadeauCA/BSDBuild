# Public domain

sub TEST_strtoll
{
	TryCompile '_MK_HAVE_STRTOLL', << 'EOF';
#include <stdlib.h>

int
main(int argc, char *argv[])
{
	long long int lli;
	char *ep = NULL;
	char *foo = "1234";

	lli = strtoll(foo, &ep, 10);
	return (lli != 0);
}
EOF
}

sub DISABLE_strtoll
{
	MkDefine('_MK_HAVE_STRTOLL', 'no');
	MkSaveUndef('_MK_HAVE_STRTOLL');
}

BEGIN
{
	my $n = 'strtoll';

	$DESCR{$n}   = 'strtoll()';
	$TESTS{$n}   = \&TEST_strtoll;
	$DISABLE{$n} = \&DISABLE_strtoll;
	$DEPS{$n}    = 'cc';
}
;1
