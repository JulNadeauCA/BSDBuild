# Public domain
# vim:ts=4

my $testCode = << 'EOF';
#include <agar/core.h>

AG_ObjectClass FooClass = {
	"FooClass",
	sizeof(AG_Object),
	{ 0,0 },
	NULL,		/* init */
	NULL,		/* reset */
	NULL,		/* destroy */
	NULL,		/* load */
	NULL,		/* save */
	NULL		/* edit */
};

int
main(int argc, char *argv[])
{
	AG_Object obj;

	AG_InitCore("conf-test", 0);
	AG_RegisterClass(&FooClass);
	AG_ObjectInitStatic(&obj, &FooClass);
	AG_ObjectDestroy(&obj);
	AG_Quit();
	return (0);
}
EOF

sub TEST_agar_core
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'agar-core-config', '--version', 'AGAR_CORE_VERSION');
	MkIfFound($pfx, $ver, 'AGAR_CORE_VERSION');
		MkPrintSN('checking whether Agar-Core works...');
		MkExecOutputPfx($pfx, 'agar-core-config', '--cflags', 'AGAR_CORE_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-core-config', '--libs', 'AGAR_CORE_LIBS');
		MkCompileC('HAVE_AGAR_CORE',
		           '${AGAR_CORE_CFLAGS}', '${AGAR_CORE_LIBS}', $testCode);
		MkSaveIfTrue('${HAVE_AGAR_CORE}', 'AGAR_CORE_CFLAGS', 'AGAR_CORE_LIBS');
	MkElse;
		DISABLE_agar_core();
	MkEndif;
}

sub DISABLE_agar_core
{
	MkDefine('HAVE_AGAR_CORE', 'no');
	MkDefine('AGAR_CORE_CFLAGS', '');
	MkDefine('AGAR_CORE_LIBS', '');
	MkSaveUndef('HAVE_AGAR_CORE', 'AGAR_CORE_CFLAGS', 'AGAR_CORE_LIBS');
}

sub EMUL_agar_core
{
	my ($os, $osrel, $machine) = @_;

	if ($os =~ /^windows/) {
		MkEmulWindows('AGAR_CORE', 'ag_core');
	} else {
		MkEmulUnavail('AGAR_CORE');
	}
	return (1);
}

BEGIN
{
	my $n = 'agar-core';

	$DESCR{$n}   = 'Agar-Core';
	$URL{$n}     = 'http://libagar.org';

	$TESTS{$n}   = \&TEST_agar_core;
	$DISABLE{$n} = \&DISABLE_agar_core;
	$EMUL{$n}    = \&EMUL_agar_core;

	$DEPS{$n}    = 'cc';
}
;1
