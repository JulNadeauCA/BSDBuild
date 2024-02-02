# Public domain

my $testCode = << 'EOF';
#include <sys/timerfd.h>

int
main(int argc, char *argv[])
{
	struct itimerspec its;
	int fd;

	if ((fd = timerfd_create(CLOCK_MONOTONIC, TFD_TIMER_ABSTIME)) != -1) {
		its.it_interval.tv_sec = 0;
		its.it_interval.tv_nsec = 0L;
		its.it_value.tv_sec = 0;
		its.it_value.tv_nsec = 0L;
		return (timerfd_settime(fd, 0, &its, NULL) == -1);
	}
	return (1);
}
EOF

sub TEST_timerfd
{
	TryCompile('HAVE_TIMERFD', $testCode);
}

sub CMAKE_timerfd
{
	my $code = MkCodeCMAKE($testCode);

	return << "EOF";
macro(Check_Timerfd)
	check_c_source_compiles("
$code" HAVE_TIMERFD)
	if (HAVE_TIMERFD)
		BB_Save_Define(HAVE_TIMERFD)
	else()
		BB_Save_Undef(HAVE_TIMERFD)
	endif()
endmacro()

macro(Disable_Timerfd)
	BB_Save_Undef(HAVE_TIMERFD)
endmacro()
EOF
}

sub DISABLE_timerfd
{
	MkDefine('HAVE_TIMERFD', 'no');
	MkSaveUndef('HAVE_TIMERFD');
}

BEGIN
{
	my $n = 'timerfd';

	$DESCR{$n}   = 'the timerfd interface';
	$TESTS{$n}   = \&TEST_timerfd;
	$CMAKE{$n}   = \&CMAKE_timerfd;
	$DISABLE{$n} = \&DISABLE_timerfd;
	$DEPS{$n}    = 'cc';
}
;1
