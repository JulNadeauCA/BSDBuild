# Public domain
# vim:ts=4

my $testCode = << 'EOF';
#include <agar/core.h>
#include <agar/math.h>

int main(int argc, char *argv[]) {
	M_Matrix *A = M_New(2,2);
	AG_InitCore("test", 0);
	M_InitSubsystem();
	M_SetIdentity(A);
	AG_Destroy();
	return (0);
}
EOF

sub Test_AgarMath
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
		Disable_AgarMath();
	MkEndif;
	return (0);
}

sub Disable_AgarMath
{
	MkSaveUndef('HAVE_AGAR_MATH',
	            'AGAR_MATH_CFLAGS',
	            'AGAR_MATH_LIBS');
}

sub Emul
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

	$DESCR{$n} = 'Agar-Math';
	$URL{$n}   = 'http://libagar.org';

	$TESTS{$n}   = \&Test_AgarMath;
	$DISABLE{$n} = \&Disable_AgarMath;
	$EMUL{$n}    = \&Emul;
	
	$DEPS{$n} = 'cc,agar';
}

;1
