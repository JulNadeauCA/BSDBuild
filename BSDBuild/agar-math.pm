# Public domain

my $testCode = << 'EOF';
#include <agar/core.h>
#include <agar/gui.h>
#include <agar/math/m.h>

int main(int argc, char *argv[]) {
	M_Matrix *A = M_New(2,2);
	AG_InitCore("test", 0);
	M_InitSubsystem();
	M_SetIdentity(A);
	AG_Destroy();
	return (0);
}
EOF

sub TEST_agar_math
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'agar-math-config', '--version', 'AGAR_MATH_VERSION');
	MkIfFound($pfx, $ver, 'AGAR_MATH_VERSION');
		MkPrintSN('checking whether Agar-Math works...');
		MkExecOutputPfx($pfx, 'agar-config', '--cflags', 'AGAR_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-config', '--libs', 'AGAR_LIBS');
		MkExecOutputPfx($pfx, 'agar-math-config', '--cflags', 'AGAR_MATH_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-math-config', '--libs', 'AGAR_MATH_LIBS');
		MkCompileC('HAVE_AGAR_MATH',
		           '${AGAR_MATH_CFLAGS} ${AGAR_CFLAGS}',
		           '${AGAR_MATH_LIBS} ${AGAR_LIBS}', $testCode);
		MkIfFalse('${HAVE_AGAR_MATH}');
			MkDisableFailed('agar-math');
		MkEndif;
	MkElse;
		MkDisableNotFound('agar-math');
	MkEndif;
}

sub DISABLE_agar_math
{
	MkDefine('HAVE_AGAR_MATH', 'no') unless $TestFailed;
	MkDefine('AGAR_MATH_CFLAGS', '');
	MkDefine('AGAR_MATH_LIBS', '');
	MkSaveUndef('HAVE_AGAR_MATH');
}

BEGIN
{
	my $n = 'agar-math';

	$DESCR{$n}   = 'Agar-Math';
	$URL{$n}     = 'http://libagar.org';
	$TESTS{$n}   = \&TEST_agar_math;
	$DISABLE{$n} = \&DISABLE_agar_math;
	$DEPS{$n}    = 'cc,agar';
	$SAVED{$n}   = 'AGAR_MATH_CFLAGS AGAR_MATH_LIBS';
}
;1
