# Public domain

sub TEST_setproctitle
{
	TryCompile 'HAVE_SETPROCTITLE', << 'EOF';
#include <sys/types.h>
#include <unistd.h>
#include <stdlib.h>
int
main(int argc, char *argv[])
{
	setproctitle("foo %d", 1);
	return (0);
}
EOF
}

sub DISABLE_setproctitle
{
	MkDefine('HAVE_SETPROCTITLE', 'no');
	MkSaveUndef('HAVE_SETPROCTITLE');
}

BEGIN
{
	my $n = 'setproctitle';

	$DESCR{$n}   = 'setproctitle()';
	$TESTS{$n}   = \&TEST_setproctitle;
	$DISABLE{$n} = \&DISABLE_setproctitle;
	$DEPS{$n}    = 'cc';
}
;1
