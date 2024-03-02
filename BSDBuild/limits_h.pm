# Public domain

my $testCode = << 'EOF';
#include <limits.h>

int main(int argc, char *argv[]) {
	int i = INT_MIN;
	unsigned u = 0;
	long l = LONG_MIN;
	unsigned long ul = 0;
	i = INT_MAX;
	u = UINT_MAX;
	l = LONG_MAX;
	ul = ULONG_MAX;
	return (i != INT_MAX || u != UINT_MAX || l != LONG_MAX || ul != LONG_MAX);
}
EOF

sub TEST_limits_h
{
	MkCompileC('_MK_HAVE_LIMITS_H', '', '', $testCode);
}

sub CMAKE_limits_h
{
	my $code = MkCodeCMAKE($testCode);

	return << "EOF";
macro(Check_Limits_h)
	check_c_source_compiles("
$code" _MK_HAVE_LIMITS_H)
	if (_MK_HAVE_LIMITS_H)
		BB_Save_Define(_MK_HAVE_LIMITS_H)
	else()
		BB_Save_Undef(_MK_HAVE_LIMITS_H)
	endif()
endmacro()
EOF
}

sub DISABLE_limits_h
{
	MkDefine('_MK_HAVE_LIMITS_H', 'no');
	MkSaveUndef('_MK_HAVE_LIMITS_H');
}

BEGIN
{
	my $n = 'limits_h';

	$DESCR{$n}   = 'compatible <limits.h>';
	$TESTS{$n}   = \&TEST_limits_h;
	$CMAKE{$n}   = \&CMAKE_limits_h;
	$DISABLE{$n} = \&DISABLE_limits_h;
	$DEPS{$n}    = 'cc';
}
;1
