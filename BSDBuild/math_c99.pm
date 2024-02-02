# Public domain

my $testCode = << 'EOF';
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
		MkDisableNotFound('math_c99');
		MkCaseEnd;
	MkCaseBegin('*');
		MkCompileC('HAVE_MATH_C99',
		           '${CFLAGS} ${MATH_C99_CFLAGS}',
		           '${MATH_C99_LIBS}', $testCode);
		MkIfFalse('${HAVE_MATH_C99}');
			MkDisableFailed('math_c99');
		MkEndif;
		MkCaseEnd;
	MkEsac;
}

sub CMAKE_math_c99
{
	my $code = MkCodeCMAKE($testCode);

	return << "EOF";
macro(Check_Math_C99)
	set(ORIG_CMAKE_REQUIRED_LIBRARIES \${CMAKE_REQUIRED_LIBRARIES})

	set(MATH_C99_CFLAGS "")
	set(MATH_C99_LIBS "")

	if (MINGW)
		message("Disabling C99 math due to libmingwex linker errors")
		BB_Save_Undef(HAVE_MATH_C99)
	else()
		check_library_exists(m pow "" HAVE_LIBM_POW)
		if (HAVE_LIBM_POW)
			set(CMAKE_REQUIRED_LIBRARIES m)
			set(MATH_C99_LIBS "-lm")
		endif()

		check_c_source_compiles("
$code" HAVE_MATH_C99)
		if (HAVE_MATH_C99)
			BB_Save_Define(HAVE_MATH_C99)
		else()
			BB_Save_Undef(HAVE_MATH_C99)
		endif()
	endif()

	BB_Save_MakeVar(MATH_C99_CFLAGS "\${MATH_C99_CFLAGS}")
	BB_Save_MakeVar(MATH_C99_LIBS "\${MATH_C99_LIBS}")

	set(CMAKE_REQUIRED_LIBRARIES \${ORIG_CMAKE_REQUIRED_LIBRARIES})
endmacro()

macro(Disable_Math_C99)
	BB_Save_Undef(HAVE_MATH_C99)
	BB_Save_MakeVar(MATH_C99_CFLAGS "")
	BB_Save_MakeVar(MATH_C99_LIBS "")
endmacro()
EOF
}

sub DISABLE_math_c99
{
	MkDefine('HAVE_MATH_C99', 'no') unless $TestFailed;
	MkDefine('MATH_C99_CFLAGS', '');
	MkDefine('MATH_C99_LIBS', '');
	MkSaveUndef('HAVE_MATH_C99');
}

BEGIN
{
	my $n = 'math_c99';

	$DESCR{$n}   = 'the C math library (C99)';
	$TESTS{$n}   = \&TEST_math_c99;
	$CMAKE{$n}   = \&CMAKE_math_c99;
	$DISABLE{$n} = \&DISABLE_math_c99;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'MATH_C99_CFLAGS MATH_C99_LIBS';
}
;1
