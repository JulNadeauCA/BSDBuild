# Public domain

my $testCode = << 'EOF';
#include <stdio.h>
int
main(int argc, char *argv[])
{
	FILE *f = fopen("/dev/null","r");
	int fdp;

	return fdclose(f, &fdp);
}
EOF

sub TEST_fdclose
{
	TryCompile('HAVE_FDCLOSE', $testCode);
}

sub CMAKE_fdclose
{
	my $code = MkCodeCMAKE($testCode);

	return << "EOF";
macro(Check_Fdclose)
	check_c_source_compiles("
$code" HAVE_FDCLOSE)
	if (HAVE_FDCLOSE)
		BB_Save_Define(HAVE_FDCLOSE)
	else()
		BB_Save_Undef(HAVE_FDCLOSE)
	endif()
endmacro()
EOF
}

sub DISABLE_fdclose
{
	MkDefine('HAVE_FDCLOSE', 'no');
	MkSaveUndef('HAVE_FDCLOSE');
}

BEGIN
{
	my $n = 'fdclose';

	$DESCR{$n}   = 'a fdclose() function';
	$TESTS{$n}   = \&TEST_fdclose;
	$CMAKE{$n}   = \&CMAKE_fdclose;
	$DISABLE{$n} = \&DISABLE_fdclose;
	$DEPS{$n}    = 'cc';
}
;1
