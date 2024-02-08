# Public domain

my $testCode = << 'EOF';
#include <stdlib.h>

int
main(int argc, char *argv[])
{
	long long int lli;
	char *ep = NULL;
	char *foo = "1234";

	lli = strtoll(foo, &ep, 10);
	return (lli != 0);
}
EOF

sub TEST_strtoll
{
	TryCompile('_MK_HAVE_STRTOLL', $testCode);
}

sub CMAKE_strtoll
{
	my $code = MkCodeCMAKE($testCode);

	return << "EOF";
macro(Check_Strtoll)
	check_c_source_compiles("
$code" _MK_HAVE_STRTOLL)
	if (_MK_HAVE_STRTOLL)
		BB_Save_Define(_MK_HAVE_STRTOLL)
	else()
		BB_Save_Undef(_MK_HAVE_STRTOLL)
	endif()
endmacro()
EOF
}

sub DISABLE_strtoll
{
	MkDefine('_MK_HAVE_STRTOLL', 'no');
	MkSaveUndef('_MK_HAVE_STRTOLL');
}

BEGIN
{
	my $n = 'strtoll';

	$DESCR{$n}   = 'strtoll()';
	$TESTS{$n}   = \&TEST_strtoll;
	$CMAKE{$n}   = \&CMAKE_strtoll;
	$DISABLE{$n} = \&DISABLE_strtoll;
	$DEPS{$n}    = 'cc';
}
;1
