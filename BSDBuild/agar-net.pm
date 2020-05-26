# Public domain

my $testCode = << 'EOF';
#include <agar/core.h>
#include <agar/net.h>

int main(int argc, char *argv[]) {
	AG_NetSocket *ns;

	if (AG_InitCore(NULL, 0) == -1) {
		return (1);
	}
	AG_InitNetworkSubsystem(NULL);
	ns = AG_NetSocketNew(AG_NET_INET4, AG_NET_STREAM, 0);
	AG_NetSocketFree(ns);
	AG_DestroyNetworkSubsystem();
	AG_Destroy();
	return (0);
}
EOF

sub TEST_agar_net
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'agar-net-config', '--version', 'AGAR_NET_VERSION');
	MkIfFound($pfx, $ver, 'AGAR_NET_VERSION');
		MkPrintSN('checking whether Agar-Net works...');
		MkExecOutputPfx($pfx, 'agar-core-config', '--cflags', 'AGAR_CORE_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-core-config', '--libs', 'AGAR_CORE_LIBS');
		MkExecOutputPfx($pfx, 'agar-net-config', '--cflags', 'AGAR_NET_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-net-config', '--libs', 'AGAR_NET_LIBS');
		MkCompileC('HAVE_AGAR_NET',
		           '${AGAR_NET_CFLAGS} ${AGAR_CORE_CFLAGS}',
		           '${AGAR_NET_LIBS} ${AGAR_CORE_LIBS}', $testCode);
		MkIfFalse('${HAVE_AGAR_NET}');
			MkDisableFailed('agar-net');
		MkEndif;
	MkElse;
		MkDisableNotFound('agar-net');
	MkEndif;
}

sub DISABLE_agar_net
{
	MkDefine('HAVE_AGAR_NET', 'no') unless $TestFailed;
	MkDefine('AGAR_NET_CFLAGS', '');
	MkDefine('AGAR_NET_LIBS', '');
	MkSaveUndef('HAVE_AGAR_NET');
}

sub EMUL_agar_net
{
	my ($os, $osrel, $machine) = @_;

	if ($os =~ /^windows/) {
		MkEmulWindows('AGAR_NET', 'ag_net');
	} else {
		MkEmulUnavail('AGAR_NET');
	}
	return (1);
}

BEGIN
{
	my $n = 'agar-net';

	$DESCR{$n}   = 'Agar-Net';
	$URL{$n}     = 'http://libagar.org';
	$TESTS{$n}   = \&TEST_agar_net;
	$DISABLE{$n} = \&DISABLE_agar_net;
	$EMUL{$n}    = \&EMUL_agar_net;
	$DEPS{$n}    = 'cc,agar-core';
	$SAVED{$n}   = 'AGAR_NET_CFLAGS AGAR_NET_LIBS';
}
;1
