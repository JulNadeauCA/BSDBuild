# Public domain

my $testCode = << 'EOF';
#include <unistd.h>

int
main(int argc, char *argv[])
{
	char *args[3] = { "foo", NULL, NULL };
	int rv;

	rv = execvp(args[0], args);
	return (rv);
}
EOF

sub TEST_execvp
{
	TryCompile('HAVE_EXECVP', $testCode);
}

sub CMAKE_execvp
{
	my $code = MkCodeCMAKE($testCode);

	return << "EOF";
macro(Check_Execvp)
	check_c_source_compiles("
$code" HAVE_EXECVP)
	if (HAVE_EXECVP)
		BB_Save_Define(HAVE_EXECVP)
	else()
		BB_Save_Undef(HAVE_EXECVP)
	endif()
endmacro()
EOF
}

sub DISABLE_execvp
{
	MkDefine('HAVE_EXECVP', 'no');
	MkSaveUndef('HAVE_EXECVP');
}

BEGIN
{
	my $n = 'execvp';

	$DESCR{$n}   = 'the execvp() function';
	$TESTS{$n}   = \&TEST_execvp;
	$CMAKE{$n}   = \&CMAKE_execvp;
	$DISABLE{$n} = \&DISABLE_execvp;
	$DEPS{$n}    = 'cc';
}
;1
