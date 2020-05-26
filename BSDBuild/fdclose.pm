# Public domain

sub TEST_fdclose
{
	TryCompile 'HAVE_FDCLOSE', << 'EOF';
#include <stdio.h>
int
main(int argc, char *argv[])
{
	FILE *f = fopen("/dev/null","r");
	int fdp;
	return fdclose(f, &fdp);
}
EOF
}

sub DISABLE_fdclose
{
	MkDefine('HAVE_FDCLOSE', 'no');
	MkSaveUndef('HAVE_FDCLOSE');
}

BEGIN
{
	my $n = 'fdclose';

	$DESCR{$n}   = 'a fdclose() function';
	$TESTS{$n}   = \&TEST_fdclose;
	$DISABLE{$n} = \&DISABLE_fdclose;
	$DEPS{$n}    = 'cc';
}
;1
