# Public domain

my $testCode = << 'EOF';
#include <stdlib.h>

int
main(int argc, char *argv[])
{
	(void)getenv("PATH");
	return (0);
}
EOF

sub TEST_getenv
{
	TryCompile('HAVE_GETENV', $testCode);
}

sub CMAKE_getenv
{
	my $code = MkCodeCMAKE($testCode);

	return << "EOF";
macro(Check_Getenv)
	check_c_source_compiles("
$code" HAVE_GETENV)
	if (HAVE_GETENV)
		BB_Save_Define(HAVE_GETENV)
	else()
		BB_Save_Undef(HAVE_GETENV)
	endif()
endmacro()
EOF
}

sub DISABLE_getenv
{
	MkDefine('HAVE_GETENV', 'no');
	MkSaveUndef('HAVE_GETENV');
}

BEGIN
{
	my $n = 'getenv';

	$DESCR{$n}   = 'getenv()';
	$TESTS{$n}   = \&TEST_getenv;
	$CMAKE{$n}   = \&CMAKE_getenv;
	$DISABLE{$n} = \&DISABLE_getenv;
	$DEPS{$n}    = 'cc';
}
;1
