# Public domain

sub TEST_gethostbyname
{
	TryCompile 'HAVE_GETHOSTBYNAME', << 'EOF';
#include <string.h>
#include <netdb.h>

int
main(int argc, char *argv[])
{
	struct hostent *hp;
	const char *host = "localhost";

	hp = gethostbyname(host);
	return (hp == NULL);
}
EOF
}

sub DISABLE_gethostbyname
{
	MkDefine('HAVE_GETHOSTBYNAME');
	MkSaveUndef('HAVE_GETHOSTBYNAME');
}

BEGIN
{
	my $n = 'gethostbyname';

	$DESCR{$n}   = 'gethostbyname()';
	$TESTS{$n}   = \&TEST_gethostbyname;
	$DISABLE{$n} = \&DISABLE_gethostbyname;
	$DEPS{$n}    = 'cc';
}
;1
