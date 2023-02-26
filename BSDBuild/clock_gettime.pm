# Public domain

my $testCode = << 'EOF';
#include <time.h>
int
main(int argc, char *argv[])
{
	struct timespec ts;
	clock_gettime(CLOCK_REALTIME, &ts);
#ifdef __FreeBSD__
	clock_gettime(CLOCK_SECOND, &ts);
#endif
	return (0);
}
EOF

sub TEST_clock_gettime
{
	MkDefine('CLOCK_CFLAGS', '');
	MkDefine('CLOCK_LIBS', '');

	MkCompileC('HAVE_CLOCK_GETTIME',
	           '${CLOCK_CFLAGS}', '${CLOCK_LIBS}',
	           $testCode);
	MkIfTrue('${HAVE_CLOCK_GETTIME}');
		MkSaveDefine('HAVE_CLOCK_GETTIME');
	MkElse;
		MkPrintSN('checking for clock_gettime() interface (with -lrt)...');
		MkCompileC('HAVE_CLOCK_GETTIME',
		           '${CLOCK_CFLAGS}', '-lrt',
		           $testCode);
		MkIfTrue('${HAVE_CLOCK_GETTIME}');
			MkDefine('CLOCK_LIBS', '-lrt');
			MkSaveDefine('HAVE_CLOCK_GETTIME');
		MkElse;
			MkDisableFailed('clock_gettime');
		MkEndif;
	MkEndif;
}

sub DISABLE_clock_gettime
{
	MkDefine('HAVE_CLOCK_GETTIME', 'no') unless $TestFailed;
	MkDefine('CLOCK_CFLAGS', '');
	MkDefine('CLOCK_LIBS', '');
	MkSaveUndef('HAVE_CLOCK_GETTIME');
}

BEGIN
{
	my $n = 'clock_gettime';

	$DESCR{$n}   = 'clock_gettime() interface (w/o -lrt)';
	$TESTS{$n}   = \&TEST_clock_gettime;
	$DISABLE{$n} = \&DISABLE_clock_gettime;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'CLOCK_CFLAGS CLOCK_LIBS';
}
;1
