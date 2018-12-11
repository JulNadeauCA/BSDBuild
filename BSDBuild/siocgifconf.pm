# vim:ts=4
# Public domain

sub TEST_siocgifconf
{
	TryCompile 'HAVE_SIOCGIFCONF', << 'EOF';
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <sys/time.h>
#include <unistd.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <net/if.h>
#include <netdb.h>
int
main(int argc, char *argv[])
{
	char buf[4096];
	struct ifconf conf;
	struct ifreq *ifr;
	int sock;
	if ((sock = socket(AF_INET, SOCK_DGRAM, 0)) == -1) {
		return (1);
	}
	conf.ifc_len = sizeof(buf);
	conf.ifc_buf = (caddr_t)buf;
	if (ioctl(sock, SIOCGIFCONF, &conf) < 0) {
		return (1);
	}
#if !defined(_SIZEOF_ADDR_IFREQ)
#define _SIZEOF_ADDR_IFREQ sizeof
#endif
	for (ifr = (struct ifreq *)buf;
	     (char *)ifr < &buf[conf.ifc_len];
	     ifr = (struct ifreq *)((char *)ifr + _SIZEOF_ADDR_IFREQ(*ifr))) {
		if (ifr->ifr_addr.sa_family == AF_INET)
			return (1);
	}
	close(sock);
	return (0);
}
EOF
}

sub DISABLE_siocgifconf
{
	MkDefine('HAVE_SIOCGIFCONF', 'no');
	MkSaveUndef('HAVE_SIOCGIFCONF');
}

BEGIN
{
	my $n = 'siocgifconf';

	$DESCR{$n}   = 'the SIOCGIFCONF interface';
	$TESTS{$n}   = \&TEST_siocgifconf;
	$DISABLE{$n} = \&DISABLE_siocgifconf;
	$DEPS{$n}    = 'cc';
}
;1
