# Public domain

sub TEST_gethostname
{
	TryCompile 'HAVE_GETHOSTNAME', << 'EOF';
#include <sys/types.h>
#include <unistd.h>

int
main(int argc, char *argv[])
{
	char hostname[64];
	int rv;

	rv = gethostname(hostname, sizeof(hostname));
	return (0);
}
EOF
}

sub DISABLE_gethostname
{
	MkDefine('HAVE_GETHOSTNAME', 'no');
	MkSaveUndef('HAVE_GETHOSTNAME');
}

BEGIN
{
	my $n = 'gethostname';

	$DESCR{$n}   = 'gethostname()';
	$TESTS{$n}   = \&TEST_gethostname;
	$DISABLE{$n} = \&DISABLE_gethostname;
	$EMUL{$n}    = \&EMUL_gethostname;
	$DEPS{$n}    = 'cc';
}
;1
