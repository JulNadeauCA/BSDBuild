# Public domain
# vim:ts=4

my $testCode = << 'EOF';
#include <time.h>
int
main(int argc, char *argv[])
{
	struct timespec ts;
	clock_gettime(CLOCK_REALTIME, &ts);
	return (0);
}
EOF

sub TEST_clock_gettime
{
	MkDefine('CLOCK_CFLAGS', '');
	MkDefine('CLOCK_LIBS', '');

	MkCompileC('HAVE_CLOCK_GETTIME', '${CLOCK_CFLAGS}',
	    '${CLOCK_LIBS}', $testCode);
	MkIfTrue('${HAVE_CLOCK_GETTIME}');
		MkSaveDefine('HAVE_CLOCK_GETTIME', 'CLOCK_CFLAGS', 'CLOCK_LIBS');
		MkSaveMK('CLOCK_CFLAGS', 'CLOCK_LIBS');
	MkElse;
		MkPrintSN('checking for clock_gettime() interface (with -lrt)...');
		MkCompileC('HAVE_CLOCK_GETTIME', '${CLOCK_CFLAGS}', '-lrt', $testCode);
		MkIfTrue('${HAVE_CLOCK_GETTIME}');
			MkDefine('CLOCK_LIBS', '-lrt');
			MkSaveDefine('HAVE_CLOCK_GETTIME', 'CLOCK_CFLAGS', 'CLOCK_LIBS');
			MkSaveMK('CLOCK_CFLAGS', 'CLOCK_LIBS');
		MkElse;
			MkSaveUndef('HAVE_CLOCK_GETTIME');
		MkEndif;
	MkEndif;
}

sub DISABLE_clock_gettime
{
	MkDefine('HAVE_CLOCK_GETTIME', 'no');
	MkDefine('CLOCK_CFLAGS', '');
	MkDefine('CLOCK_LIBS', '');
	MkSaveUndef('HAVE_CLOCK_GETTIME', 'CLOCK_CFLAGS', 'CLOCK_LIBS');
}

BEGIN
{
	my $n = 'clock_gettime';

	$DESCR{$n}   = 'clock_gettime() interface (w/o -lrt)';
	$TESTS{$n}   = \&TEST_clock_gettime;
	$DISABLE{$n} = \&DISABLE_clock_gettime;
	$DEPS{$n}    = 'cc';
}
;1
