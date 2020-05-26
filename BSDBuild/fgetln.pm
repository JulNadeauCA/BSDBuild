# Public domain

sub TEST_fgetln
{
	TryCompile 'HAVE_FGETLN', << 'EOF';
#include <stdio.h>

int
main(int argc, char *argv[])
{
	FILE *f;
	size_t size;
	char *s;

	f = fopen("foo", "r");
	s = fgetln(f, &size);
	printf("%s\n", s);
	fclose(f);
	return (0);
}
EOF
}

sub DISABLE_fgetln
{
	MkDefine('HAVE_FGETLN', 'no');
	MkSaveUndef('HAVE_FGETLN');
}

BEGIN
{
	my $n = 'fgetln';

	$DESCR{$n}   = 'fgetln()';
	$TESTS{$n}   = \&TEST_fgetln;
	$DISABLE{$n} = \&DISABLE_fgetln;
	$DEPS{$n}    = 'cc';
}
;1
