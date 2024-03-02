# Public domain

my $testCode = << 'EOF';
#include <agar/core.h>
#include <agar/vg.h>

int main(int argc, char *argv[]) {
	VG *vg;
	AG_InitCore(NULL, 0);
	VG_InitSubsystem();
	if ((vg = VG_New(0)) != NULL) {
		AG_ObjectDestroy(vg);
	}
	VG_DestroySubsystem();
	AG_Quit();
	return (0);
}
EOF

sub TEST_agar_vg
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'agar-vg-config', '--version', 'AGAR_VG_VERSION');
	MkIfFound($pfx, $ver, 'AGAR_VG_VERSION');
		MkPrintSN('checking whether agar-vg works...');
		MkExecOutputPfx($pfx, 'agar-config', '--cflags', 'AGAR_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-config', '--libs', 'AGAR_LIBS');
		MkExecOutputPfx($pfx, 'agar-vg-config', '--cflags', 'AGAR_VG_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-vg-config', '--libs', 'AGAR_VG_LIBS');
		MkCompileC('HAVE_AGAR_VG',
		           '${AGAR_VG_CFLAGS} ${AGAR_CFLAGS}',
		           '${AGAR_VG_LIBS} ${AGAR_LIBS}', $testCode);
		MkIfFalse('${HAVE_AGAR_VG}');
			MkDisableFailed('agar-vg');
		MkEndif;
	MkElse;
		MkDisableNotFound('agar-vg');
	MkEndif;
}

sub DISABLE_agar_vg
{
	MkDefine('HAVE_AGAR_VG', 'no') unless $TestFailed;
	MkDefine('AGAR_VG_CFLAGS', '');
	MkDefine('AGAR_VG_LIBS', '');
	MkSaveUndef('HAVE_AGAR_VG');
}

BEGIN
{
	my $n = 'agar-vg';

	$DESCR{$n}   = 'Agar-VG';
	$URL{$n}     = 'http://libagar.org';
	$TESTS{$n}   = \&TEST_agar_vg;
	$DISABLE{$n} = \&DISABLE_agar_vg;
	$DEPS{$n}    = 'cc,agar';
	$SAVED{$n}   = 'AGAR_VG_CFLAGS AGAR_VG_LIBS';
}
;1
