# Public domain

my $testCode = << 'EOF';
#include <agar/core.h>
#include <agar/gui.h>
#include <agar/sk.h>

int main(int argc, char *argv[]) {
	SK *sk;
	sk = SK_New(NULL, "foo");
	AG_ObjectDestroy(sk);
	return (0);
}
EOF

sub TEST_agar_sk
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'agar-sk-config', '--version', 'AGAR_SK_VERSION');
	MkIfFound($pfx, $ver, 'AGAR_SK_VERSION');
		MkPrintSN('checking whether Agar-SK works...');
		MkExecOutputPfx($pfx, 'agar-config', '--cflags', 'AGAR_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-config', '--libs', 'AGAR_LIBS');
		MkExecOutputPfx($pfx, 'agar-sk-config', '--cflags', 'AGAR_SK_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-sk-config', '--libs', 'AGAR_SK_LIBS');
		MkCompileC('HAVE_AGAR_SK',
		           '${AGAR_SK_CFLAGS} ${AGAR_MATH_CFLAGS} ${AGAR_CFLAGS}',
		           '${AGAR_SK_LIBS} ${AGAR_MATH_LIBS} ${AGAR_LIBS}',
		           $testCode);
		MkIfFalse('${HAVE_AGAR_SK}');
			MkDisableFailed('agar-sk');
		MkEndif;
	MkElse;
		MkDisableNotFound('agar-sk');
	MkEndif;
}

sub DISABLE_agar_sk
{
	MkDefine('HAVE_AGAR_SK', 'no') unless $TestFailed;
	MkDefine('AGAR_SK_CFLAGS', '');
	MkDefine('AGAR_SK_LIBS', '');
	MkSaveUndef('HAVE_AGAR_SK');
}

sub EMUL_agar_sk
{
	my ($os, $osrel, $machine) = @_;

	if ($os =~ /^windows/) {
		MkEmulWindows('AGAR_SK', 'ag_sk');
	} else {
		MkEmulUnavail('AGAR_SK');
	}
	return (1);
}

BEGIN
{
	my $n = 'agar-sk';

	$DESCR{$n}   = 'Agar-SK';
	$URL{$n}     = 'http://libagar.org';
	$TESTS{$n}   = \&TEST_agar_sk;
	$DISABLE{$n} = \&DISABLE_agar_sk;
	$EMUL{$n}    = \&EMUL_agar_sk;
	$DEPS{$n}    = 'cc,agar';
	$SAVED{$n}   = 'AGAR_SK_CFLAGS AGAR_SK_LIBS';

	@{$EMULDEPS{$n}} = qw(agar);
}
;1
