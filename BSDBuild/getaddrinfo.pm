# Public domain
# vim:ts=4

sub Test
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

sub Disable
{
	MkDefine('HAVE_GETADDRINFO', 'no');
	MkSaveUndef('HAVE_GETADDRINFO');
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	# Note: This is available in the "winsock" test.

	MkEmulUnavail('GETADDRINFO');
	return (1);
}

BEGIN
{
	my $n = 'getaddrinfo';
	
	$DESCR{$n} = 'getaddrinfo()';

	$TESTS{$n}   = \&Test;
	$DISABLE{$n} = \&Disable;
	$EMUL{$n}    = \&Emul;
	
	$DEPS{$n} = 'cc';
}

;1
