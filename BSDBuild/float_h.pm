# Public domain

my $testCode = << 'EOF';
#include <float.h>

int main(int argc, char *argv[]) {
	float flt = 0.0f;
	double dbl = 0.0;

	flt += FLT_EPSILON;
	dbl += DBL_EPSILON;
	return (0);
}
EOF

sub TEST_float_h
{
	MkCompileC('_MK_HAVE_FLOAT_H', '', '', $testCode);
}

sub CMAKE_float_h
{
	my $code = MkCodeCMAKE($testCode);

	return << "EOF";
macro(Check_Float_h)
	check_c_source_compiles("
$code" _MK_HAVE_FLOAT_H)
	if (_MK_HAVE_FLOAT_H)
		BB_Save_Define(_MK_HAVE_FLOAT_H)
	else()
		BB_Save_Undef(_MK_HAVE_FLOAT_H)
	endif()
endmacro()
EOF
}

sub DISABLE_float_h
{
	MkDefine('_MK_HAVE_FLOAT_H', 'no');
	MkSaveUndef('_MK_HAVE_FLOAT_H');
}

BEGIN
{
	my $n = 'float_h';

	$DESCR{$n}   = '<float.h>';
	$TESTS{$n}   = \&TEST_float_h;
	$CMAKE{$n}   = \&CMAKE_float_h;
	$DISABLE{$n} = \&DISABLE_float_h;
	$DEPS{$n}    = 'cc';
}
;1
