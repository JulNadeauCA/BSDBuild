# vim:ts=4
# Public domain

my $testCode = << 'EOF';
#include <agar/core.h>
#include <agar/gui.h>
#include <freesg/rg.h>

int main(int argc, char *argv[]) {
	RG_Tileset *ts;

	ts = RG_TilesetNew(NULL, "foo", 0);
	AG_ObjectDestroy(ts);
	return (0);
}
EOF

sub TEST_freesg_rg
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'freesg-rg-config', '--version', 'FREESG_RG_VERSION');
	MkIfFound($pfx, $ver, 'FREESG_RG_VERSION');
		MkPrintSN('checking whether FreeSG-RG works...');
		MkExecOutputPfx($pfx, 'agar-config', '--cflags', 'AGAR_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-config', '--libs', 'AGAR_LIBS');
		MkExecOutputPfx($pfx, 'freesg-rg-config', '--cflags', 'FREESG_RG_CFLAGS');
		MkExecOutputPfx($pfx, 'freesg-rg-config', '--libs', 'FREESG_RG_LIBS');
		MkCompileC('HAVE_FREESG_RG',
		           '${FREESG_RG_CFLAGS} ${AGAR_CFLAGS}',
		           '${FREESG_RG_LIBS} ${AGAR_LIBS}',
				   $testCode);
		MkSaveIfTrue('${HAVE_FREESG_RG}', 'FREESG_RG_CFLAGS', 'FREESG_RG_LIBS');
	MkElse;
		DISABLE_freesg_rg();
	MkEndif;
}

sub DISABLE_freesg_rg
{
	MkDefine('HAVE_FREESG_RG', 'no');
	MkDefine('FREESG_RG_CFLAGS', '');
	MkDefine('FREESG_RG_LIBS', '');
	MkSaveUndef('HAVE_FREESG_RG', 'FREESG_RG_CFLAGS', 'FREESG_RG_LIBS');
}

sub EMUL_freesg_rg
{
	my ($os, $osrel, $machine) = @_;

	if ($os =~ /^windows/) {
		MkEmulWindows('FREESG_RG', 'freesg_rg');
	} else {
		MkEmulUnavail('FREESG_RG');
	}
	return (1);
}

BEGIN
{
	my $n = 'freesg-rg';

	$DESCR{$n}   = 'FreeSG-RG';
	$URL{$n}     = 'http://freesg.org';
	$TESTS{$n}   = \&TEST_freesg_rg;
	$DISABLE{$n} = \&DISABLE_freesg_rg;
	$EMUL{$n}    = \&EMUL_freesg_rg;
	$DEPS{$n}    = 'cc,agar';
}
;1
