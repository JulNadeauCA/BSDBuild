# Public domain
# vim:ts=4

my $testCode = << 'EOF';
#include <agar/core.h>
#include <agar/gui.h>
#include <agar/dev.h>

int main(int argc, char *argv[]) {
	AG_Object obj;

	AG_ObjectInitStatic(&obj, &agObjectClass);
	DEV_InitSubsystem(0);
	DEV_Browser(&obj);
	AG_ObjectDestroy(&obj);
	return (0);
}
EOF

sub TEST_agar_dev
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'agar-dev-config', '--version', 'AGAR_DEV_VERSION');
	MkIfFound($pfx, $ver, 'AGAR_DEV_VERSION');
		MkPrintSN('checking whether Agar-DEV works...');
		MkExecOutputPfx($pfx, 'agar-config', '--cflags', 'AGAR_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-config', '--libs', 'AGAR_LIBS');
		MkExecOutputPfx($pfx, 'agar-dev-config', '--cflags', 'AGAR_DEV_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-dev-config', '--libs', 'AGAR_DEV_LIBS');
		MkCompileC('HAVE_AGAR_DEV',
		           '${AGAR_DEV_CFLAGS} ${AGAR_CFLAGS}',
				   '${AGAR_DEV_LIBS} ${AGAR_LIBS}',
				   $testCode);
		MkSaveIfTrue('${HAVE_AGAR_DEV}', 'AGAR_DEV_CFLAGS', 'AGAR_DEV_LIBS');
	MkElse;
		DISABLE_agar_dev();
	MkEndif;
}

sub DISABLE_agar_dev
{
	MkDefine('HAVE_AGAR_DEV', 'no');
	MkDefine('AGAR_DEV_CFLAGS', '');
	MkDefine('AGAR_DEV_LIBS', '');
	MkSaveUndef('HAVE_AGAR_DEV', 'AGAR_DEV_CFLAGS', 'AGAR_DEV_LIBS');
}

sub EMUL_agar_dev
{
	my ($os, $osrel, $machine) = @_;

	if ($os =~ /^windows/) {
		MkEmulWindows('AGAR_DEV', 'ag_dev');
	} else {
		MkEmulUnavail('AGAR_DEV');
	}
	return (1);
}

BEGIN
{
	my $n = 'agar-dev';

	$DESCR{$n} = 'Agar-DEV';
	$URL{$n}   = 'http://libagar.org';

	$TESTS{$n}   = \&TEST_agar_dev;
	$DISABLE{$n} = \&DISABLE_agar_dev;
	$EMUL{$n}    = \&EMUL_agar_dev;
	
	$DEPS{$n}  = 'cc,agar';
}
;1
