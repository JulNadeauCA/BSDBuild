# Public domain

my $testCode = << 'EOF';
#include <time.h>

int
main(int argc, char *argv[])
{
	struct timespec rqtp, rmtp;
	int rv;

	rqtp.tv_sec = 1;
	rqtp.tv_nsec = 1000000;
	rv = nanosleep(&rqtp, &rmtp);
	return (rv == -1);
}
EOF

sub TEST_nanosleep
{
	TryCompile('HAVE_NANOSLEEP', $testCode);
}

sub CMAKE_nanosleep
{
	my $code = MkCodeCMAKE($testCode);

	return << "EOF";
macro(Check_Nanosleep)
	check_c_source_compiles("
$code" HAVE_NANOSLEEP)
	if (HAVE_NANOSLEEP)
		BB_Save_Define(HAVE_NANOSLEEP)
	else()
		BB_Save_Undef(HAVE_NANOSLEEP)
	endif()
endmacro()
EOF
}

sub DISABLE_nanosleep
{
	MkDefine('HAVE_NANOSLEEP', 'no');
	MkSaveUndef('HAVE_NANOSLEEP');
}

BEGIN
{
	my $n = 'nanosleep';

	$DESCR{$n}   = 'nanosleep()';
	$TESTS{$n}   = \&TEST_nanosleep;
	$CMAKE{$n}   = \&CMAKE_nanosleep;
	$DISABLE{$n} = \&DISABLE_nanosleep;
	$DEPS{$n}    = 'cc';
}
;1
