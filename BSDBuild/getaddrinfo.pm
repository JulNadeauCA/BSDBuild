# Public domain
# vim:ts=4

sub TEST_getaddrinfo
{
	TryCompile 'HAVE_GETADDRINFO', << 'EOF';
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>

int
main(int argc, char *argv[])
{
	struct addrinfo hints, *res0;
	const char *s;
	int rv;

	hints.ai_family = PF_UNSPEC;
	hints.ai_socktype = SOCK_STREAM;
	hints.ai_flags = AI_PASSIVE;
	rv = getaddrinfo("hostname", "port", &hints, &res0);
	s = gai_strerror(rv);
	freeaddrinfo(res0);
	return (s != NULL);
}
EOF
}

sub DISABLE_getaddrinfo
{
	MkDefine('HAVE_GETADDRINFO', 'no');
	MkSaveUndef('HAVE_GETADDRINFO');
}

BEGIN
{
	my $n = 'getaddrinfo';
	
	$DESCR{$n}   = 'getaddrinfo()';
	$TESTS{$n}   = \&TEST_getaddrinfo;
	$DISABLE{$n} = \&DISABLE_getaddrinfo;
	$DEPS{$n}    = 'cc';
}
;1
