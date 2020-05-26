# Public domain

sub TEST_flock
{
	TryCompile 'HAVE_FLOCK', << 'EOF';
#include <sys/file.h>

int
main(int argc, char *argv[])
{
	int fd = 0;
	flock(fd, LOCK_EX);
	flock(fd, LOCK_UN);
	return (0);
}
EOF
}

sub DISABLE_flock
{
	MkDefine('HAVE_FLOCK', 'no');
	MkSaveUndef('HAVE_FLOCK');
}

BEGIN
{
	my $n = 'flock';

	$DESCR{$n}   = 'the flock() function';
	$TESTS{$n}   = \&TEST_flock;
	$DISABLE{$n} = \&DISABLE_flock;
	$DEPS{$n}    = 'cc';
}
;1
