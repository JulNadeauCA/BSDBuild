# vim:ts=4
# Public domain

sub TEST_nanosleep
{
	TryCompile 'HAVE_NANOSLEEP', << 'EOF';
#include <time.h>

int
main(int argc, char *argv[])
{
	struct timespec rqtp, rmtp;
	int rv;

	rqtp.tv_sec = 1;
	rqtp.tv_nsec = 1000000;
	rv = nanosleep(&rqtp, &rmtp);
	return (rv == -1);
}
EOF
}

sub DISABLE_nanosleep
{
	MkDefine('HAVE_NANOSLEEP', 'no');
	MkSaveUndef('HAVE_NANOSLEEP');
}

BEGIN
{
	my $n = 'nanosleep';

	$DESCR{$n}   = 'nanosleep()';
	$TESTS{$n}   = \&TEST_nanosleep;
	$DISABLE{$n} = \&DISABLE_nanosleep;
	$DEPS{$n}    = 'cc';
}
;1
