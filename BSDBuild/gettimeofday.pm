# Public domain

my $testCode = << 'EOF';
#include <sys/time.h>
#include <stdio.h>

int
main(int argc, char *argv[])
{
	struct timeval tv;
	int rv = gettimeofday(&tv, NULL);
	return (rv);
}
EOF

sub TEST_gettimeofday
{
	TryCompile('HAVE_GETTIMEOFDAY', $testCode);
}

sub CMAKE_gettimeofday
{
	my $code = MkCodeCMAKE($testCode);

	return << "EOF";
macro(Check_Gettimeofday)
	check_c_source_compiles("
$code" HAVE_GETTIMEOFDAY)
	if (HAVE_GETTIMEOFDDAY)
		BB_Save_Define(HAVE_GETTIMEOFDAY)
	else()
		BB_Save_Undef(HAVE_GETTIMEOFDAY)
	endif()
endmacro()
EOF
}

sub DISABLE_gettimeofday
{
	MkDefine('HAVE_GETTIMEOFDAY', 'no');
	MkSaveUndef('HAVE_GETTIMEOFDAY');
}

BEGIN
{
	my $n = 'gettimeofday';

	$DESCR{$n}   = 'gettimeofday()';
	$TESTS{$n}   = \&TEST_gettimeofday;
	$CMAKE{$n}   = \&CMAKE_gettimeofday;
	$DISABLE{$n} = \&DISABLE_gettimeofday;
	$DEPS{$n}    = 'cc';
}
;1
