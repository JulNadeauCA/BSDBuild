# Public domain
# vim:ts=4

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
		           '${AGAR_MATH_LIBS} ${AGAR_LIBS}',
				   $testCode);
		MkSaveIfTrue('${HAVE_AGAR_MATH}', 'AGAR_MATH_CFLAGS', 'AGAR_MATH_LIBS');
	MkElse;
		DISABLE_agar_math();
	MkEndif;
}

sub DISABLE_agar_math
{
	MkDefine('HAVE_AGAR_MATH', 'no');
	MkDefine('AGAR_MATH_CFLAGS', '');
	MkDefine('AGAR_MATH_LIBS', '');
	MkSaveUndef('HAVE_AGAR_MATH', 'AGAR_MATH_CFLAGS', 'AGAR_MATH_LIBS');
}

sub EMUL_agar_math
{
	my ($os, $osrel, $machine) = @_;

	if ($os =~ /^windows/) {
		MkEmulWindows('AGAR_MATH', 'ag_math');
	} else {
		MkEmulUnavail('AGAR_MATH');
	}
	return (1);
}

BEGIN
{
	my $n = 'agar-math';

	$DESCR{$n}   = 'Agar-Math';
	$URL{$n}     = 'http://libagar.org';

	$TESTS{$n}   = \&TEST_agar_math;
	$DISABLE{$n} = \&DISABLE_agar_math;
	$EMUL{$n}    = \&EMUL_agar_math;
	
	$DEPS{$n}    = 'cc,agar';
}
;1
