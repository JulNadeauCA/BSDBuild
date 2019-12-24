# vim:ts=4
# Public domain

my $testCode = << 'EOF';
#include <agar/core.h>
#include <agar/gui.h>
#include <agar/map.h>

int main(int argc, char *argv[]) {
	MAP *m;
	if (AG_InitCore(NULL, 0) == -1) { return (1); }
	m = MAP_New(NULL, "foo");
	AG_ObjectDestroy(m);
	AG_Destroy();
	return (0);
}
EOF

sub TEST_agar_map
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'agar-map-config', '--version', 'AGAR_MAP_VERSION');
	MkIfFound($pfx, $ver, 'AGAR_MAP_VERSION');
		MkPrintSN('checking whether Agar-MAP works...');
		MkExecOutputPfx($pfx, 'agar-config', '--cflags', 'AGAR_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-config', '--libs', 'AGAR_LIBS');
		MkExecOutputPfx($pfx, 'agar-rg-config', '--cflags', 'AGAR_RG_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-rg-config', '--libs', 'AGAR_RG_LIBS');
		MkExecOutputPfx($pfx, 'agar-map-config', '--cflags', 'AGAR_MAP_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-map-config', '--libs', 'AGAR_MAP_LIBS');
		MkCompileC('HAVE_AGAR_MAP',
		           '${AGAR_MAP_CFLAGS} ${AGAR_RG_CFLAGS} ${AGAR_CFLAGS}',
		           '${AGAR_MAP_LIBS} ${AGAR_RG_LIBS} ${AGAR_LIBS}',
		           $testCode);
		MkSaveIfTrue('${HAVE_AGAR_MAP}', 'AGAR_MAP_CFLAGS', 'AGAR_MAP_LIBS');
	MkElse;
		DISABLE_agar_map();
	MkEndif;
}

sub DISABLE_agar_map
{
	MkDefine('HAVE_AGAR_MAP', 'no');
	MkDefine('AGAR_MAP_CFLAGS', '');
	MkDefine('AGAR_MAP_LIBS', '');
	MkSaveUndef('HAVE_AGAR_MAP', 'AGAR_MAP_CFLAGS', 'AGAR_MAP_LIBS');
}

sub EMUL_agar_map
{
	my ($os, $osrel, $machine) = @_;

	if ($os =~ /^windows/) {
		MkEmulWindows('AGAR_MAP', 'ag_map');
	} else {
		MkEmulUnavail('AGAR_MAP');
	}
	return (1);
}

BEGIN
{
	my $n = 'agar-map';

	$DESCR{$n}   = 'Agar-MAP';
	$URL{$n}     = 'http://libagar.org';
	$TESTS{$n}   = \&TEST_agar_map;
	$DISABLE{$n} = \&DISABLE_agar_map;
	$EMUL{$n}    = \&EMUL_agar_map;
	$DEPS{$n}    = 'cc,agar,agar-rg';

#	@{$EMULDEPS{$n}} = qw(agar);
}
;1
