# Public domain

sub TEST_float_h
{
	MkCompileC('_MK_HAVE_FLOAT_H', '', '', << 'EOF');
#include <float.h>

int main(int argc, char *argv[]) {
	float flt = 0.0f;
	double dbl = 0.0;

	flt += FLT_EPSILON;
	dbl += DBL_EPSILON;
	return (0);
}
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
	$DISABLE{$n} = \&DISABLE_float_h;
	$DEPS{$n}    = 'cc';
}
;1
