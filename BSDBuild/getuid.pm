# vim:ts=4
# Public domain

sub TEST_getuid
{
	TryCompile 'HAVE_GETUID', << 'EOF';
#include <sys/types.h>
#include <unistd.h>

int
main(int argc, char *argv[])
{
	uid_t uid = getuid();
	return (uid != 0);
}
EOF
}

sub DISABLE_getuid
{
	MkDefine('HAVE_GETUID', 'no');
	MkSaveUndef('HAVE_GETUID');
}

BEGIN
{
	my $n = 'getuid';

	$DESCR{$n}   = 'getuid()';
	$TESTS{$n}   = \&TEST_getuid;
	$DISABLE{$n} = \&DISABLE_getuid;
	$DEPS{$n}    = 'cc';
}
;1
