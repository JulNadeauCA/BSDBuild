# Public domain

my $testCode = << 'EOF';
#include <agar/core.h>
#include <agar/micro.h>

int
main(int argc, char *argv[])
{
	AG_InitCore(NULL, 0);
	MA_InitGraphics(AG_NULL);
#ifdef AG_EVENT_LOOP
	AG_EventLoop();
#endif
	AG_Quit();
	return (0);
}
EOF

sub TEST_agar_micro
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'agar-micro-config', '--version', 'AGAR_MICRO_VERSION');
	MkIfFound($pfx, $ver, 'AGAR_MICRO_VERSION');
		MkPrintSN('checking whether micro-Agar works...');
		MkExecOutputPfx($pfx, 'agar-micro-config', '--cflags', 'AGAR_MICRO_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-micro-config', '--libs', 'AGAR_MICRO_LIBS');
		MkCompileC('HAVE_AGAR_MICRO',
		           '${AGAR_MICRO_CFLAGS}', '${AGAR_MICRO_LIBS}', $testCode);
		MkIfFalse('${HAVE_AGAR_MICRO}');
			MkDisableFailed('agar-micro');
		MkEndif;
	MkElse;
		MkDisableNotFound('agar-micro');
	MkEndif;
}

sub DISABLE_agar_micro
{
	MkDefine('HAVE_AGAR_MICRO', 'no') unless $TestFailed;
	MkDefine('AGAR_MICRO_CFLAGS', '');
	MkDefine('AGAR_MICRO_LIBS', '');
	MkSaveUndef('HAVE_AGAR_MICRO');
}

BEGIN
{
	my $n = 'agar-micro';

	$DESCR{$n}   = 'Micro-Agar';
	$URL{$n}     = 'http://libagar.org';
	$TESTS{$n}   = \&TEST_agar_micro;
	$DISABLE{$n} = \&DISABLE_agar_micro;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'AGAR_MICRO_CFLAGS AGAR_MICRO_LIBS';
}
;1
