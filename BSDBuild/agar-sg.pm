# Public domain

my $testCode = << 'EOF';
#include <agar/core.h>
#include <agar/gui.h>
#include <agar/sg.h>

int main(int argc, char *argv[]) {
	SG *sg;
	sg = SG_New(NULL, "foo", 0);
	AG_ObjectDestroy(sg);
	return (0);
}
EOF

sub TEST_agar_sg
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'agar-sg-config', '--version', 'AGAR_SG_VERSION');
	MkIfFound($pfx, $ver, 'AGAR_SG_VERSION');
		MkPrintSN('checking whether Agar-SG works...');
		MkExecOutputPfx($pfx, 'agar-config', '--cflags', 'AGAR_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-config', '--libs', 'AGAR_LIBS');
		MkExecOutputPfx($pfx, 'agar-sg-config', '--cflags', 'AGAR_SG_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-sg-config', '--libs', 'AGAR_SG_LIBS');
		MkCompileC('HAVE_AGAR_SG',
		           '${AGAR_SG_CFLAGS} ${AGAR_MATH_CFLAGS} ${AGAR_CFLAGS}',
		           '${AGAR_SG_LIBS} ${AGAR_MATH_LIBS} ${AGAR_LIBS}',
		           $testCode);
		MkIfFalse('${HAVE_AGAR_SG}');
			MkDisableFailed('agar-sg');
		MkEndif;
	MkElse;
		MkDisableNotFound('agar-sg');
	MkEndif;
}

sub DISABLE_agar_sg
{
	MkDefine('HAVE_AGAR_SG', 'no') unless $TestFailed;
	MkDefine('AGAR_SG_CFLAGS', '');
	MkDefine('AGAR_SG_LIBS', '');
	MkSaveUndef('HAVE_AGAR_SG');
}

BEGIN
{
	my $n = 'agar-sg';

	$DESCR{$n}   = 'Agar-SG';
	$URL{$n}     = 'http://libagar.org';
	$TESTS{$n}   = \&TEST_agar_sg;
	$DISABLE{$n} = \&DISABLE_agar_sg;
	$DEPS{$n}    = 'cc,agar,agar-math';
	$SAVED{$n}   = 'AGAR_SG_CFLAGS AGAR_SG_LIBS';
}
;1
