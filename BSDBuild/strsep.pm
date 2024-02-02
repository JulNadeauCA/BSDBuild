# Public domain

my $testCode = << 'EOF';
#include <string.h>

int
main(int argc, char *argv[])
{
	char foo[32], *pFoo = &foo[0];
	char *s;

	foo[0] = 0;
	s = strsep(&pFoo, " ");
	return (s != NULL);
}
EOF

sub TEST_strsep
{
	TryCompile('HAVE_STRSEP', $testCode);
}

sub CMAKE_strsep
{
	my $code = MkCodeCMAKE($testCode);

	return << "EOF";
macro(Check_Strsep)
	check_c_source_compiles("
$code" HAVE_STRSEP)
	if (HAVE_STRSEP)
		BB_Save_Define(HAVE_STRSEP)
	else()
		BB_Save_Undef(HAVE_STRSEP)
	endif()
endmacro()
EOF
}

sub DISABLE_strsep
{
	MkDefine('HAVE_STRSEP', 'no');
	MkSaveUndef('HAVE_STRSEP');
}

BEGIN
{
	my $n = 'strsep';

	$DESCR{$n}   = 'strsep()';
	$TESTS{$n}   = \&TEST_strsep;
	$CMAKE{$n}   = \&CMAKE_strsep;
	$DISABLE{$n} = \&DISABLE_strsep;
	$DEPS{$n}    = 'cc';
}
;1
