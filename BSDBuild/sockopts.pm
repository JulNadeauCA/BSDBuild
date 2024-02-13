# Public domain

my $testCodeSetsockopt = << 'EOF';
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

my $testCodeSoOobInline = << 'EOF';
#include <sys/types.h>
#include <sys/socket.h>
#include <fcntl.h>
int
main(int argc, char *argv[])
{
	int fd = 0, val = 1, rv;
	socklen_t valLen = sizeof(val);
	rv = setsockopt(fd, SOL_SOCKET, SO_OOBINLINE, &val, valLen);
	return (rv != 0);
}
EOF

my $testCodeSoOobInline = << 'EOF';
#include <sys/types.h>
#include <sys/socket.h>
#include <fcntl.h>
int
main(int argc, char *argv[])
{
	int fd = 0, val = 1, rv;
	socklen_t valLen = sizeof(val);
	rv = setsockopt(fd, SOL_SOCKET, SO_OOBINLINE, &val, valLen);
	return (rv != 0);
}
EOF

my $testCodeSoReusePort = << 'EOF';
#include <sys/types.h>
#include <sys/socket.h>
#include <fcntl.h>
int
main(int argc, char *argv[])
{
	int fd = 0, val = 1, rv;
	socklen_t valLen = sizeof(val);
	rv = setsockopt(fd, SOL_SOCKET, SO_REUSEPORT, &val, valLen);
	return (rv != 0);
}
EOF

my $testCodeSoTimestamp = << 'EOF';
#include <sys/types.h>
#include <sys/socket.h>
#include <fcntl.h>
int
main(int argc, char *argv[])
{
	int fd = 0, val = 1, rv;
	socklen_t valLen = sizeof(val);
	rv = setsockopt(fd, SOL_SOCKET, SO_TIMESTAMP, &val, valLen);
	return (rv != 0);
}
EOF

my $testCodeSoNoSigPipe = << 'EOF';
#include <sys/types.h>
#include <sys/socket.h>
#include <fcntl.h>
int
main(int argc, char *argv[])
{
	int fd = 0, val = 1, rv;
	socklen_t valLen = sizeof(val);
	rv = setsockopt(fd, SOL_SOCKET, SO_NOSIGPIPE, &val, valLen);
	return (rv != 0);
}
EOF

my $testCodeSoLinger = << 'EOF';
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

my $testCodeSoAcceptFilter = << 'EOF';
#include <sys/types.h>
#include <sys/socket.h>
#include <fcntl.h>
int
main(int argc, char *argv[])
{
	int fd = 0, rv;
	struct accept_filter_arg afa;
	socklen_t afaLen = sizeof(afa);
	afa.af_name[0] = 'A';
	afa.af_arg[0] = 'A';
	rv = setsockopt(fd, SOL_SOCKET, SO_ACCEPTFILTER, &afa, afaLen);
	return (rv != 0);
}
EOF

sub TEST_setsockopt
{
	TryCompile('HAVE_SETSOCKOPT', $testCodeSetsockopt);
	MkIfTrue('${HAVE_SETSOCKOPT}');
		MkPrintSN('checking for SO_OOBINLINE...');
		TryCompile('HAVE_SO_OOBINLINE', $testCodeSoOobInline);
		MkPrintSN('checking for SO_REUSEPORT...');
		TryCompile('HAVE_SO_REUSEPORT', $testCodeSoReusePort);
		MkPrintSN('checking for SO_TIMESTAMP...');
		TryCompile('HAVE_SO_TIMESTAMP', $testCodeSoTimestamp);
		MkPrintSN('checking for SO_NOSIGPIPE...');
		TryCompile('HAVE_SO_NOSIGPIPE', $testCodeSoNoSigPipe);
		MkPrintSN('checking for SO_LINGER...');
		TryCompile('HAVE_SO_LINGER', $testCodeSoLinger);
		MkPrintSN('checking for SO_ACCEPTFILTER...');
		TryCompile('HAVE_SO_ACCEPTFILTER', $testCodeSoAcceptFilter);
	MkElse;
		DISABLE_setsockopt();
	MkEndif;
}

sub CMAKE_setsockopt
{
	my $codeSetsockopt = MkCodeCMAKE($testCodeSetsockopt);
	my $codeSoOobInline = MkCodeCMAKE($testCodeSoOobInline);
	my $codeSoReusePort = MkCodeCMAKE($testCodeSoReusePort);
	my $codeSoTimestamp = MkCodeCMAKE($testCodeSoTimestamp);
	my $codeSoNoSigPipe = MkCodeCMAKE($testCodeSoNoSigPipe);
	my $codeSoLinger = MkCodeCMAKE($testCodeSoLinger);
	my $codeSoAcceptFilter = MkCodeCMAKE($testCodeSoAcceptFilter);

	return << "EOF";
macro(Check_Setsockopts)

	check_c_source_compiles("
$codeSetsockopt" HAVE_SETSOCKOPT)
	if (HAVE_SETSOCKOPT)
		BB_Save_Define(HAVE_SETSOCKOPT)
	else()
		BB_Save_Undef(HAVE_SETSOCKOPT)
	endif()

	check_c_source_compiles("
$codeSoOobInline" HAVE_SO_OOBINLINE)
	if (HAVE_SO_OOBINLINE)
		BB_Save_Define(HAVE_SO_OOBINLINE)
	else()
		BB_Save_Undef(HAVE_SO_OOBINLINE)
	endif()

	check_c_source_compiles("
$codeSoReusePort" HAVE_SO_REUSEPORT)
	if (HAVE_SO_REUSEPORT)
		BB_Save_Define(HAVE_SO_REUSEPORT)
	else()
		BB_Save_Undef(HAVE_SO_REUSEPORT)
	endif()

	check_c_source_compiles("
$codeSoTimestamp" HAVE_SO_TIMESTAMP)
	if (HAVE_SO_TIMESTAMP)
		BB_Save_Define(HAVE_SO_TIMESTAMP)
	else()
		BB_Save_Undef(HAVE_SO_TIMESTAMP)
	endif()

	check_c_source_compiles("
$codeSoNoSigPipe" HAVE_SO_NOSIGPIPE)
	if (HAVE_SO_NOSIGPIPE)
		BB_Save_Define(HAVE_SO_NOSIGPIPE)
	else()
		BB_Save_Undef(HAVE_SO_NOSIGPIPE)
	endif()

	check_c_source_compiles("
$codeSoLinger" HAVE_SO_LINGER)
	if (HAVE_SO_LINGER)
		BB_Save_Define(HAVE_SO_LINGER)
	else()
		BB_Save_Undef(HAVE_SO_LINGER)
	endif()

	check_c_source_compiles("
$codeSoAcceptFilter" HAVE_SO_ACCEPTFILTER)
	if (HAVE_SO_ACCEPTFILTER)
		BB_Save_Define(HAVE_SO_ACCEPTFILTER)
	else()
		BB_Save_Undef(HAVE_SO_ACCEPTFILTER)
	endif()


endmacro()

macro(Disable_Setsockopts)
	BB_Save_Undef(HAVE_SETSOCKOPT)
	BB_Save_Undef(HAVE_SO_OOBINLINE)
	BB_Save_Undef(HAVE_SO_REUSEPORT)
	BB_Save_Undef(HAVE_SO_TIMESTAMP)
	BB_Save_Undef(HAVE_SO_NOSIGPIPE)
	BB_Save_Undef(HAVE_SO_LINGER)
	BB_Save_Undef(HAVE_SO_ACCEPTFILTER)
endmacro()
EOF
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

	MkSaveUndef('HAVE_SETSOCKOPT', 'HAVE_SO_OOBINLINE', 'HAVE_SO_REUSEPORT',
	            'HAVE_SO_TIMESTAMP', 'HAVE_SO_NOSIGPIPE', 'HAVE_SO_LINGER',
	            'HAVE_SO_ACCEPTFILTER');
}

BEGIN
{
	my $n = 'sockopts';

	$DESCR{$n}   = 'setsockopt()';
	$TESTS{$n}   = \&TEST_setsockopt;
	$CMAKE{$n}   = \&CMAKE_setsockopt;
	$DISABLE{$n} = \&DISABLE_setsockopt;
	$DEPS{$n}    = 'cc';
}
;1
