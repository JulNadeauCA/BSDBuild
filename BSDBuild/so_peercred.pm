# Public domain

sub TEST_so_peercred
{
	TryCompile 'HAVE_SO_PEERCRED', << 'EOF';
#include <sys/types.h>
#include <sys/socket.h>

int
main(int argc, char *argv[])
{
	struct ucred creds;
	socklen_t socklen;
	int fd = 0;
	uid_t uid;
	gid_t gid;
	int rv;

	socklen = sizeof(creds);
	rv = getsockopt(fd, SOL_SOCKET, SO_PEERCRED, &creds, &socklen);
	if (rv != 0) { return (1); }
	uid = (uid_t)creds.uid;
	gid = (gid_t)creds.gid;
	return (0);
}
EOF
}

sub DISABLE_so_peercred
{
	MkDefine('HAVE_SO_PEERCRED', 'no');
	MkSaveUndef('HAVE_SO_PEERCRED');
}

BEGIN
{
	my $n = 'so_peercred';

	$DESCR{$n}   = 'the SO_PEERCRED interface';
	$TESTS{$n}   = \&TEST_so_peercred;
	$DISABLE{$n} = \&DISABLE_so_peercred;
	$DEPS{$n}    = 'cc';
}
;1
