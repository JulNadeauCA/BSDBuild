# Public domain

sub TEST_timerfd
{
	TryCompile 'HAVE_TIMERFD', << 'EOF';
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
}

sub DISABLE_timerfd
{
	MkDefine('HAVE_TIMERFD', 'no');
	MkSaveUndef('HAVE_TIMERFD');
}

BEGIN
{
	my $n = 'timerfd';

	$DESCR{$n}   = 'the Linux timerfd interface';
	$TESTS{$n}   = \&TEST_timerfd;
	$DISABLE{$n} = \&DISABLE_timerfd;
	$DEPS{$n}    = 'cc';
}
;1
