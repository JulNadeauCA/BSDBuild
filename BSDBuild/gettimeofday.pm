# vim:ts=4
# Public domain

sub TEST_gettimeofday
{
	TryCompile 'HAVE_GETTIMEOFDAY', << 'EOF';
#include <sys/time.h>
#include <stdio.h>

int
main(int argc, char *argv[])
{
	struct timeval tv;
	int rv = gettimeofday(&tv, NULL);
	return (rv);
}
EOF
}

sub DISABLE_gettimeofday
{
	MkDefine('HAVE_GETTIMEOFDAY', 'no');
	MkSaveUndef('HAVE_GETTIMEOFDAY');
}

BEGIN
{
	my $n = 'gettimeofday';

	$DESCR{$n}   = 'gettimeofday()';
	$TESTS{$n}   = \&TEST_gettimeofday;
	$DISABLE{$n} = \&DISABLE_gettimeofday;
	$DEPS{$n}    = 'cc';
}
;1
