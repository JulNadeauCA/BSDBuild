# Public domain

sub TEST_getpwuid
{
	TryCompile 'HAVE_GETPWUID', << 'EOF';
#include <string.h>
#include <sys/types.h>
#include <pwd.h>

int
main(int argc, char *argv[])
{
	struct passwd *pwd;
	uid_t uid = 0;

	pwd = getpwuid(uid);
	return (pwd != NULL && pwd->pw_dir != NULL);
}
EOF
}

sub DISABLE_getpwuid
{
	MkDefine('HAVE_GETPWUID', 'no');
	MkSaveUndef('HAVE_GETPWUID');
}

BEGIN
{
	my $n = 'getpwuid';

	$DESCR{$n} = 'getpwuid()';
	$TESTS{$n}   = \&TEST_getpwuid;
	$DISABLE{$n} = \&DISABLE_getpwuid;
	$DEPS{$n}    = 'cc';
}
;1
