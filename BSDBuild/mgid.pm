# Public domain

my $testCode = << 'EOF';
#include <mgid/mgid.h>

int main(int argc, char *argv[]) {
	int rv;
	rv = MGI_Init(0);
	MGI_Destroy();
	return (0);
}
EOF

sub TEST_mgid
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'mgid-config', '--version', 'MGID_VERSION');
	MkExecOutputPfx($pfx, 'mgid-config', '--cflags', 'MGID_CFLAGS');
	MkExecOutputPfx($pfx, 'mgid-config', '--libs', 'MGID_LIBS');
	MkIfFound($pfx, $ver, 'MGID_VERSION');
		MkPrintSN('checking whether libmgid works...');
		MkCompileC('HAVE_MGID',
		           '${MGID_CFLAGS}', '${MGID_LIBS}', $testCode);
		MkIfFalse('${HAVE_MGID}');
			MkDisableFailed('mgid');
		MkEndif;
	MkElse;
		MkDisableNotFound('mgid');
	MkEndif;
}

sub DISABLE_mgid
{
	MkDefine('HAVE_MGID', 'no') unless $TestFailed;
	MkDefine('MGID_CFLAGS', '');
	MkDefine('MGID_LIBS', '');
	MkSaveUndef('HAVE_MGID');
}

BEGIN
{
	my $n = 'mgid';

	$DESCR{$n}   = 'libmgid';
	$URL{$n}     = 'http://mgid.hypertriton.com';
	$TESTS{$n}   = \&TEST_mgid;
	$DISABLE{$n} = \&DISABLE_mgid;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'MGID_CFLAGS MGID_LIBS';
}
;1
