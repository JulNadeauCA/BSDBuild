# Public domain

my $testCode = << 'EOF';
#include <agar/core.h>

AG_ObjectClass FooClass = {
	"FooClass",
	sizeof(AG_Object),
	{ 0,0 },
	AG_NULL,		/* init */
	AG_NULL,		/* reset */
	AG_NULL,		/* destroy */
	AG_NULL,		/* load */
	AG_NULL,		/* save */
	AG_NULL			/* edit */
};

int
main(int argc, char *argv[])
{
	AG_Object obj;

	AG_InitCore("conf-test", 0);
	AG_RegisterClass(&FooClass);
	AG_ObjectInit(&obj, &FooClass);
	obj.flags |= AG_OBJECT_STATIC;
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
		           '${AGAR_CORE_CFLAGS}', '${AGAR_CORE_LIBS}',
		           $testCode);
		MkIfFalse('${HAVE_AGAR_CORE}');
			MkDisableFailed('agar-core');
		MkEndif;
	MkElse;
		MkDisableNotFound('agar-core');
	MkEndif;
}

sub DISABLE_agar_core
{
	MkDefine('HAVE_AGAR_CORE', 'no') unless $TestFailed;
	MkDefine('AGAR_CORE_CFLAGS', '');
	MkDefine('AGAR_CORE_LIBS', '');
	MkSaveUndef('HAVE_AGAR_CORE');
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
	$URL{$n}     = 'https://libagar.org';
	$TESTS{$n}   = \&TEST_agar_core;
	$DISABLE{$n} = \&DISABLE_agar_core;
	$EMUL{$n}    = \&EMUL_agar_core;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'AGAR_CORE_CFLAGS AGAR_CORE_LIBS';
}
;1
