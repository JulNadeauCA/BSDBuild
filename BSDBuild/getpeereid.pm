# Public domain

sub TEST_getpeereid
{
	TryCompile 'HAVE_GETPEEREID', << 'EOF';
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>

int
main(int argc, char *argv[])
{
	uid_t uid;
	gid_t gid;
	int fd = 0;
	int rv;

	rv = getpeereid(fd, &uid, &gid);
	if (rv != 0) { return (1); }
	return (0);
}
EOF
}

sub DISABLE_getpeereid
{
	MkDefine('HAVE_GETPEEREID', 'no');
	MkSaveUndef('HAVE_GETPEEREID');
}

BEGIN
{
	my $n = 'getpeereid';

	$DESCR{$n}   = 'the getpeereid() interface';
	$TESTS{$n}   = \&TEST_getpeereid;
	$DISABLE{$n} = \&DISABLE_getpeereid;
	$DEPS{$n}    = 'cc';
}
;1
