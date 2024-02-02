# Public domain

my $testCode = << 'EOF';
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

sub TEST_getpwuid
{
	TryCompile('HAVE_GETPWUID', $testCode);
}

sub CMAKE_getpwuid
{
	my $code = MkCodeCMAKE($testCode);

	return << "EOF";
macro(Check_Getpwuid)
	check_c_source_compiles("
$code" HAVE_GETPWUID)
	if (HAVE_GETPWUID)
		BB_Save_Define(HAVE_GETPWUID)
	else()
		BB_Save_Undef(HAVE_GETPWUID)
	endif()
endmacro()
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
	$CMAKE{$n}   = \&CMAKE_getpwuid;
	$DISABLE{$n} = \&DISABLE_getpwuid;
	$DEPS{$n}    = 'cc';
}
;1
