# Public domain

my $testCode = << 'EOF';
#include <stdlib.h>

int
main(int argc, char *argv[])
{
	(void)setenv("BSDBUILD_SETENV_TEST", "foo", 1);
	unsetenv("BSDBUILD_SETENV_TEST");
	return (0);
}
EOF

sub TEST_setenv
{
	TryCompile('HAVE_SETENV', $testCode);
}

sub CMAKE_setenv
{
	my $code = MkCodeCMAKE($testCode);

	return << "EOF";
macro(Check_Setenv)
	check_c_source_compiles("
$code" HAVE_SETENV)
	if (HAVE_SETENV)
		BB_Save_Define(HAVE_SETENV)
	else()
		BB_Save_Undef(HAVE_SETENV)
	endif()
endmacro()
EOF
}

sub DISABLE_setenv
{
	MkDefine('HAVE_SETENV', 'no');
	MkSaveUndef('HAVE_SETENV');
}

BEGIN
{
	my $n = 'setenv';

	$DESCR{$n}   = 'setenv() and unsetenv()';
	$TESTS{$n}   = \&TEST_setenv;
	$CMAKE{$n}   = \&CMAKE_setenv;
	$DISABLE{$n} = \&DISABLE_setenv;
	$DEPS{$n}    = 'cc';
}
;1
