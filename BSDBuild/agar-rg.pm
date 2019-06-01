# vim:ts=4
# Public domain

my $testCode = << 'EOF';
#include <agar/core.h>
#include <agar/gui.h>
#include <agar/rg.h>

int main(int argc, char *argv[]) {
	RG_Tileset *ts;

	ts = RG_TilesetNew(NULL, "foo", 0);
	AG_ObjectDestroy(ts);
	return (0);
}
EOF

sub TEST_agar_rg
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'agar-rg-config', '--version', 'AGAR_RG_VERSION');
	MkIfFound($pfx, $ver, 'AGAR_RG_VERSION');
		MkPrintSN('checking whether Agar-RG works...');
		MkExecOutputPfx($pfx, 'agar-config', '--cflags', 'AGAR_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-config', '--libs', 'AGAR_LIBS');
		MkExecOutputPfx($pfx, 'agar-rg-config', '--cflags', 'AGAR_RG_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-rg-config', '--libs', 'AGAR_RG_LIBS');
		MkCompileC('HAVE_AGAR_RG',
		           '${AGAR_RG_CFLAGS} ${AGAR_CFLAGS}',
		           '${AGAR_RG_LIBS} ${AGAR_LIBS}',
				   $testCode);
		MkSaveIfTrue('${HAVE_AGAR_RG}', 'AGAR_RG_CFLAGS', 'AGAR_RG_LIBS');
	MkElse;
		DISABLE_agar_rg();
	MkEndif;
}

sub DISABLE_agar_rg
{
	MkDefine('HAVE_AGAR_RG', 'no');
	MkDefine('AGAR_RG_CFLAGS', '');
	MkDefine('AGAR_RG_LIBS', '');
	MkSaveUndef('HAVE_AGAR_RG', 'AGAR_RG_CFLAGS', 'AGAR_RG_LIBS');
}

sub EMUL_agar_rg
{
	my ($os, $osrel, $machine) = @_;

	if ($os =~ /^windows/) {
		MkEmulWindows('AGAR_RG', 'agar_rg');
	} else {
		MkEmulUnavail('AGAR_RG');
	}
	return (1);
}

BEGIN
{
	my $n = 'agar-rg';

	$DESCR{$n}   = 'Agar-RG';
	$URL{$n}     = 'http://libagar.org';
	$TESTS{$n}   = \&TEST_agar_rg;
	$DISABLE{$n} = \&DISABLE_agar_rg;
	$EMUL{$n}    = \&EMUL_agar_rg;
	$DEPS{$n}    = 'cc,agar';
}
;1
