# Public domain

my $testCode = << 'EOF';
#include <sys/types.h>
#include <unistd.h>

int
main(int argc, char *argv[])
{
	uid_t uid = getuid();
	return (uid != 0);
}
EOF

sub TEST_getuid
{
	TryCompile('HAVE_GETUID', $testCode);
}

sub CMAKE_getuid
{
	my $code = MkCodeCMAKE($testCode);

	return << "EOF";
macro(Check_Getuid)
	check_c_source_compiles("
$code" HAVE_GETUID)
	if (HAVE_GETUID)
		BB_Save_Define(HAVE_GETUID)
	else()
		BB_Save_Undef(HAVE_GETUID)
	endif()
endmacro()
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
	$CMAKE{$n}   = \&CMAKE_getuid;
	$DISABLE{$n} = \&DISABLE_getuid;
	$DEPS{$n}    = 'cc';
}
;1
