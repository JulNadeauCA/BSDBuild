# Public domain

my $testCode = << 'EOF';
#include <stdlib.h>

int
main(int argc, char *argv[])
{
	double d1, d2;
	unsigned short xbuf[3] = { 1,2,3 };
	unsigned short p[7];
	long l1, l2;
	d1 = drand48(); d2 = erand48(xbuf);
	l1 = lrand48(); l2 = nrand48(xbuf);
	srand48(l1);
	lcong48(p);
	return (0);
}
EOF

sub CMAKE_rand48
{
	my $code = MkCodeCMAKE($testCode);

	return << "EOF";
macro(Check_Rand48)
	check_c_source_compiles("
$code" HAVE_RAND48)
	if (HAVE_RAND48)
		BB_Save_Define(HAVE_RAND48)
	else()
		BB_Save_Undef(HAVE_RAND48)
	endif()
endmacro()
EOF
}

sub TEST_rand48
{
	TryCompile('HAVE_RAND48', $testCode);
}

sub DISABLE_rand48
{
	MkDefine('HAVE_RAND48', 'no');
	MkSaveUndef('HAVE_RAND48');
}

BEGIN
{
	my $n = 'rand48';

	$DESCR{$n}   = 'the rand48(3) family of functions';
	$TESTS{$n}   = \&TEST_rand48;
	$CMAKE{$n}   = \&CMAKE_rand48;
	$DISABLE{$n} = \&DISABLE_rand48;
	$DEPS{$n}    = 'cc';
}
;1
