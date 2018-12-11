# vim:ts=4
# Public domain

sub TEST_signal
{
	TryCompile '_MK_HAVE_SIGNAL', << 'EOF';
#include <signal.h>
void sighandler(int sig) { }
int
main(int argc, char *argv[])
{
	signal(SIGTERM, sighandler);
	signal(SIGILL, sighandler);
	return (0);
}
EOF
}

sub DISABLE_signal
{
	MkDefine('_MK_HAVE_SIGNAL', 'no');
	MkSaveUndef('_MK_HAVE_SIGNAL');
}

BEGIN
{
	my $n = 'signal';

	$DESCR{$n}   = 'ANSI-style signal() facilities';
	$TESTS{$n}   = \&TEST_signal;
	$DISABLE{$n} = \&DISABLE_signal;
	$DEPS{$n}    = 'cc';
}
;1
