# vim:ts=4
# Public domain

sub TEST_math_c99
{
	my ($ver, $pfx) = @_;

	MkIfNE($pfx, '');
		MkDefine('MATH_C99_CFLAGS', "-I$pfx");
		MkDefine('MATH_C99_LIBS', "-L$pfx -lm");
	MkElse;
		MkDefine('MATH_C99_CFLAGS', '');
		MkDefine('MATH_C99_LIBS', '-lm');
	MkEndif;
		
	MkCaseIn('${host}');
	MkCaseBegin('*-pc-mingw32*');
		MkPrintS('skipping (libmingwex linker errors)');
		MkDefine('HAVE_MATH_C99', 'no');
		MkSaveUndef('HAVE_MATH_C99');
		MkCaseEnd;
	MkCaseBegin('*');
		MkCompileC('HAVE_MATH_C99', '${CFLAGS} ${MATH_C99_CFLAGS}', '${MATH_C99_LIBS}', << 'EOF');
#include <math.h>

int
main(int argc, char *argv[])
{
	float f = 1.0;
	double d = 1.0;

	d = fabs(d);
	f = sqrtf(fabsf(f));
	return (f > d) ? 0 : 1;
}
EOF
		MkCaseEnd;
	MkEsac;

	MkSave('MATH_C99_CFLAGS', 'MATH_C99_LIBS');
}

sub DISABLE_math_c99
{
	MkDefine('HAVE_MATH_C99', 'no');
	MkDefine('MATH_C99_CFLAGS', '');
	MkDefine('MATH_C99_LIBS', '');
	MkSaveUndef('HAVE_MATH_C99');
}

BEGIN
{
	my $n = 'math_c99';

	$DESCR{$n}   = 'the C math library (C99)';
	$TESTS{$n}   = \&TEST_math_c99;
	$DISABLE{$n} = \&DISABLE_math_c99;
	$DEPS{$n}    = 'cc';
}
;1
