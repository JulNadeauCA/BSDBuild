# vim:ts=4
# Public domain

sub CheckBoolOption
{
	my $opt = shift;

	MkPrintSN("checking for $opt...");
	TryCompile "HAVE_$opt", << "EOF";
#include <sys/types.h>
#include <sys/socket.h>
#include <fcntl.h>
int
main(int argc, char *argv[])
{
	int fd = 0, val = 1, rv;
	socklen_t valLen = sizeof(val);
	rv = setsockopt(fd, SOL_SOCKET, $opt, &val, valLen);
	return (rv != 0);
}
EOF
}

sub TEST_setsockopt
{
	TryCompile 'HAVE_SETSOCKOPT', << 'EOF';
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <fcntl.h>
int
main(int argc, char *argv[])
{
	int fd = 0, rv;
	struct timeval tv;
	socklen_t tvLen = sizeof(tv);
	tv.tv_sec = 1; tv.tv_usec = 0;
	rv = setsockopt(fd, SOL_SOCKET, SO_SNDTIMEO, &tv, tvLen);
	return (rv != 0);
}
EOF
	MkIfTrue('${HAVE_SETSOCKOPT}');
		CheckBoolOption('SO_OOBINLINE');
		CheckBoolOption('SO_REUSEPORT');
		CheckBoolOption('SO_TIMESTAMP');
		CheckBoolOption('SO_NOSIGPIPE');

		MkPrintSN('checking for SO_LINGER...');
		TryCompile 'HAVE_SO_LINGER', << 'EOF';
#include <sys/types.h>
#include <sys/socket.h>
#include <fcntl.h>
int
main(int argc, char *argv[])
{
	int fd = 0, rv;
	struct linger ling;
	socklen_t lingLen = sizeof(ling);
	ling.l_onoff = 1; ling.l_linger = 1;
	rv = setsockopt(fd, SOL_SOCKET, SO_LINGER, &ling, lingLen);
	return (rv != 0);
}
EOF
		MkPrintSN('checking for SO_ACCEPTFILTER...');
		TryCompile 'HAVE_SO_ACCEPTFILTER', << 'EOF';
#include <sys/types.h>
#include <sys/socket.h>
#include <fcntl.h>
int
main(int argc, char *argv[])
{
	int fd = 0, rv;
	struct accept_filter_arg afa;
	socklen_t afaLen = sizeof(afa);
	afa.af_name[0] = '\0';
	afa.af_arg[0] = '\0';
	rv = setsockopt(fd, SOL_SOCKET, SO_ACCEPTFILTER, &afa, afaLen);
	return (rv != 0);
}
EOF
	MkElse;
		DISABLE_setsockopt();
	MkEndif;
}

sub DISABLE_setsockopt
{
	MkDefine('HAVE_SETSOCKOPT', 'no');
	MkDefine('HAVE_SO_OOBINLINE', 'no');
	MkDefine('HAVE_SO_REUSEPORT', 'no');
	MkDefine('HAVE_SO_TIMESTAMP', 'no');
	MkDefine('HAVE_SO_NOSIGPIPE', 'no');
	MkDefine('HAVE_SO_LINGER', 'no');
	MkDefine('HAVE_SO_ACCEPTFILTER', 'no');

	MkSaveUndef('HAVE_SETSOCKOPT',
                'HAVE_SO_OOBINLINE',
	            'HAVE_SO_REUSEPORT',
	            'HAVE_SO_TIMESTAMP',
	            'HAVE_SO_NOSIGPIPE',
	            'HAVE_SO_LINGER',
	            'HAVE_SO_ACCEPTFILTER');
}

BEGIN
{
	my $n = 'sockopts';

	$DESCR{$n}   = 'setsockopt()';
	$TESTS{$n}   = \&TEST_setsockopt;
	$DISABLE{$n} = \&DISABLE_setsockopt;
	$DEPS{$n}    = 'cc';
}
;1
