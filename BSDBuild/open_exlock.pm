# Public domain

sub TEST_open_exlock
{
	TryCompile 'HAVE_OPEN_EXLOCK', << 'EOF';
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

int
main(int argc, char *argv[])
{
	int fd;

	fd = open("foo", O_WRONLY|O_CREAT|O_EXLOCK);
	close(fd);
	return (0);
}
EOF
}

sub DISABLE_open_exlock
{
	MkDefine('HAVE_OPEN_EXLOCK', 'no');
	MkSaveUndef('HAVE_OPEN_EXLOCK');
}

BEGIN
{
	my $n = 'open_exlock';

	$DESCR{$n}   = 'open() with O_EXLOCK';
	$TESTS{$n}   = \&TEST_open_exlock;
	$DISABLE{$n} = \&DISABLE_open_exlock;
	$DEPS{$n}    = 'cc';
}
;1
