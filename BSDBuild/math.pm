# Public domain

my $testCode = << 'EOF';
#include <math.h>

int
main(int argc, char *argv[])
{
	double d = 1.0;
	d = fabs(d);
	return (0);
}
EOF

sub TEST_math
{
	my ($ver, $pfx) = @_;

	MkIfNE($pfx, '');
		MkDefine('MATH_CFLAGS', "-I$pfx");
		MkDefine('MATH_LIBS', "-L$pfx -lm");
	MkElse;
		MkDefine('MATH_CFLAGS', '');
		MkDefine('MATH_LIBS', '-lm');
	MkEndif;

	MkCompileC('HAVE_MATH', '${CFLAGS} ${MATH_CFLAGS}', '${MATH_LIBS}', $testCode);
}

sub CMAKE_math
{
	my $code = MkCodeCMAKE($testCode);

	return << "EOF";
macro(Check_Math)
	set(ORIG_CMAKE_REQUIRED_LIBRARIES \${CMAKE_REQUIRED_LIBRARIES})

	set(MATH_CFLAGS "")
	set(MATH_LIBS "")

	check_library_exists(m pow "" HAVE_LIBM_POW)
	if (HAVE_LIBM_POW)
		set(CMAKE_REQUIRED_LIBRARIES "m")
		set(MATH_LIBS "-lm")
	endif()

	check_c_source_compiles("
$code" HAVE_MATH)
	if (HAVE_MATH)
		BB_Save_Define(HAVE_MATH)
	else()
		BB_Save_Undef(HAVE_MATH)
	endif()

	BB_Save_MakeVar(MATH_CFLAGS "\${MATH_CFLAGS}")
	BB_Save_MakeVar(MATH_LIBS "\${MATH_LIBS}")

	set(CMAKE_REQUIRED_LIBRARIES \${ORIG_CMAKE_REQUIRED_LIBRARIES})
endmacro()

macro(Disable_Math)
	BB_Save_Undef(HAVE_MATH)
endmacro()
EOF
}

sub DISABLE_math
{
	MkDefine('HAVE_MATH', 'no');
	MkDefine('MATH_CFLAGS', '');
	MkDefine('MATH_LIBS', '');
	MkSaveUndef('HAVE_MATH');
}

sub EMUL_math
{
	my ($os, $osrel, $machine) = @_;

	if ($os =~ /^windows/) {
		MkEmulWindows('MATH', '');
	} else {
		MkEmulUnavail('MATH');
	}
	return (1);
}

BEGIN
{
	my $n = 'math';

	$DESCR{$n}   = 'the C math library';
	$TESTS{$n}   = \&TEST_math;
	$CMAKE{$n}   = \&CMAKE_math;
	$DISABLE{$n} = \&DISABLE_math;
	$EMUL{$n}    = \&EMUL_math;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'MATH_CFLAGS MATH_LIBS';
}
;1
